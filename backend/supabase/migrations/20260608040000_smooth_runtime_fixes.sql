-- Custom dare chat FK, custom proof submissions, storage upsert, challenge seed, hardened onboarding.

-- ─── Challenge catalog (idempotent) ─────────────────────────────────────────

insert into public.challenges (id, time_label, text, points, hook, minutes, rules, sort_order)
values
  ('00000000-0000-0000-0000-000000000001', '6 min', 'Let yo bih go thru yo phone', 20,
   'Oh hell naw jigsaw u tweaking bruh', 6,
   'Hand your phone unlocked to someone in the room for 6 minutes. They can scroll anything except banking apps.', 1),
  ('00000000-0000-0000-0000-000000000002', '9 min', 'Text your ex', 10, 'Yes.', 9,
   'Send one honest text to your ex. No scheduling a call.', 2),
  ('00000000-0000-0000-0000-000000000003', '2 hrs', 'Run 10 km', 50,
   'Burn some calories', 120,
   'Continuous run or walk. Strava / Apple Health / a sweaty selfie counts as proof.', 3),
  ('00000000-0000-0000-0000-000000000004', '5 hrs', 'Larp having money', 60,
   'Larp larp larp sahur', 300,
   'Post a story flexing obvious fake wealth for at least 5 hours.', 4),
  ('00000000-0000-0000-0000-000000000005', '1 min', 'Make a dumb joke', null,
   'Pure embarrassment', 1,
   'Tell the joke out loud to at least two people. Groans = success.', 5)
on conflict (id) do nothing;

-- ─── Custom dare chat messages ───────────────────────────────────────────────

alter table public.chat_messages
  add column if not exists dare_custom_challenge_id uuid
    references public.custom_challenges (id) on delete set null;

create index if not exists chat_messages_custom_dare_idx
  on public.chat_messages (dare_custom_challenge_id)
  where dare_custom_challenge_id is not null;

alter table public.chat_messages
  drop constraint if exists chat_messages_single_dare_ref_check;

alter table public.chat_messages
  add constraint chat_messages_single_dare_ref_check
  check (
    dare_challenge_id is null
    or dare_custom_challenge_id is null
  );

-- ─── Custom dare proof submissions ───────────────────────────────────────────

alter table public.submissions
  alter column challenge_id drop not null;

alter table public.submissions
  add column if not exists custom_challenge_id uuid
    references public.custom_challenges (id) on delete restrict;

alter table public.submissions
  drop constraint if exists submissions_single_challenge_ref_check;

alter table public.submissions
  add constraint submissions_single_challenge_ref_check
  check (
    (challenge_id is not null and custom_challenge_id is null)
    or (challenge_id is null and custom_challenge_id is not null)
  );

create or replace function public.handle_submission_review()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  challenge_points integer;
begin
  if old.status = new.status then
    return new;
  end if;

  if new.status = 'approved' and old.status = 'pending' then
    if new.challenge_id is not null then
      select c.points into challenge_points
      from public.challenges c
      where c.id = new.challenge_id;
    elsif new.custom_challenge_id is not null then
      select cc.points into challenge_points
      from public.custom_challenges cc
      where cc.id = new.custom_challenge_id;
    end if;

    new.points_awarded := coalesce(challenge_points, 0);
    new.reviewed_at := coalesce(new.reviewed_at, now());

    update public.profiles p
    set
      total_points = p.total_points + coalesce(new.points_awarded, 0),
      quest_done = least(p.quest_total, p.quest_done + 1),
      wins = p.wins + 1,
      challenges_completed = p.challenges_completed + 1,
      updated_at = now()
    where p.id = new.user_id;

    insert into public.notifications (user_id, title, body, kind)
    select
      new.user_id,
      'Proof approved',
      '+' || coalesce(new.points_awarded, 0)::text || 'pts for your dare',
      'proof'::public.notification_kind;
  elsif new.status = 'rejected' and old.status = 'pending' then
    new.reviewed_at := coalesce(new.reviewed_at, now());

    insert into public.notifications (user_id, title, body, kind)
    values (
      new.user_id,
      'Proof rejected',
      coalesce(new.review_note, 'Your photo did not pass review.'),
      'proof'::public.notification_kind
    );
  end if;

  new.updated_at := now();
  return new;
end;
$$;

-- ─── Storage proof re-uploads ────────────────────────────────────────────────

drop policy if exists "Users update own proof photos" on storage.objects;
create policy "Users update own proof photos"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ─── Harden first-time group creation ────────────────────────────────────────

create or replace function public.ensure_primary_group(group_name text default 'Chaos Crew')
returns public.groups
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  existing_group public.groups;
  created_group public.groups;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  perform pg_advisory_xact_lock(hashtextextended(uid::text, 0));

  select g.*
  into existing_group
  from public.groups g
  join public.group_members gm on gm.group_id = g.id
  where gm.user_id = uid
  order by gm.joined_at asc
  limit 1;

  if found then
    return existing_group;
  end if;

  insert into public.groups (name, created_by)
  values (group_name, uid)
  returning * into created_group;

  insert into public.group_members (group_id, user_id, role)
  values (created_group.id, uid, 'admin');

  return created_group;
end;
$$;

grant execute on function public.ensure_primary_group(text) to authenticated;

-- ─── Invite join ─────────────────────────────────────────────────────────────

create or replace function public.join_group_by_invite(p_invite_code text)
returns public.groups
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  target public.groups;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select * into target
  from public.groups g
  where lower(g.invite_code) = lower(trim(p_invite_code))
  limit 1;

  if not found then
    raise exception 'Invalid invite code';
  end if;

  insert into public.group_members (group_id, user_id, role)
  values (target.id, uid, 'member')
  on conflict do nothing;

  return target;
end;
$$;

grant execute on function public.join_group_by_invite(text) to authenticated;
