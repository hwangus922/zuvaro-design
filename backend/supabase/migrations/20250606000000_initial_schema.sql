-- Zuvaro production schema
-- Auth: Supabase Auth (Apple, email). Moderation: admin review on submissions.

create extension if not exists "pgcrypto";

-- ─── Profiles ───────────────────────────────────────────────────────────────

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default 'Zuvaro Player',
  handle text unique,
  avatar_emoji text not null default '🍳',
  total_points integer not null default 0 check (total_points >= 0),
  quest_done integer not null default 0 check (quest_done >= 0),
  quest_total integer not null default 5 check (quest_total > 0),
  wins integer not null default 0,
  longest_streak integer not null default 0,
  challenges_completed integer not null default 0,
  is_admin boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index profiles_handle_idx on public.profiles (handle);
create index profiles_total_points_idx on public.profiles (total_points desc);

-- ─── Groups (friend crews) ─────────────────────────────────────────────────

create table public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text not null unique default encode(gen_random_bytes(6), 'hex'),
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.group_members (
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null default 'member' check (role in ('member', 'admin')),
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

create index group_members_user_idx on public.group_members (user_id);

-- ─── Challenge catalog ───────────────────────────────────────────────────────

create table public.challenges (
  id uuid primary key default gen_random_uuid(),
  time_label text not null,
  text text not null,
  points integer,
  hook text not null,
  minutes integer not null check (minutes > 0),
  rules text not null,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create index challenges_active_sort_idx on public.challenges (is_active, sort_order);

-- ─── Submissions (proof upload + admin review) ───────────────────────────────

create type public.submission_status as enum ('pending', 'approved', 'rejected');

create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  challenge_id uuid not null references public.challenges (id) on delete restrict,
  group_id uuid references public.groups (id) on delete set null,
  caption text,
  photo_path text not null,
  status public.submission_status not null default 'pending',
  points_awarded integer,
  review_note text,
  reviewed_by uuid references public.profiles (id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index submissions_user_idx on public.submissions (user_id, created_at desc);
create index submissions_status_idx on public.submissions (status, created_at desc);

-- ─── Chat ────────────────────────────────────────────────────────────────────

create table public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  text text not null,
  is_dare boolean not null default false,
  dare_challenge_id uuid references public.challenges (id) on delete set null,
  created_at timestamptz not null default now()
);

create index chat_messages_group_idx on public.chat_messages (group_id, created_at);

-- ─── Notifications ───────────────────────────────────────────────────────────

create type public.notification_kind as enum ('proof', 'dare', 'board', 'friend');

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  body text not null,
  kind public.notification_kind not null,
  unread boolean not null default true,
  created_at timestamptz not null default now()
);

create index notifications_user_idx on public.notifications (user_id, created_at desc);

-- ─── Social safety ───────────────────────────────────────────────────────────

create table public.blocked_users (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

-- ─── Auto-create profile on signup ───────────────────────────────────────────

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  base_handle text;
  final_handle text;
begin
  base_handle := coalesce(
    nullif(split_part(new.email, '@', 1), ''),
    'player'
  );
  final_handle := '@' || lower(regexp_replace(base_handle, '[^a-zA-Z0-9_]', '', 'g'));
  if final_handle = '@' then
    final_handle := '@player';
  end if;

  insert into public.profiles (id, display_name, handle)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', 'Zuvaro Player'),
    final_handle || substr(replace(new.id::text, '-', ''), 1, 4)
  );

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ─── Admin review: award points on approval ──────────────────────────────────

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
    select c.points into challenge_points
    from public.challenges c
    where c.id = new.challenge_id;

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

create trigger on_submission_reviewed
  before update of status on public.submissions
  for each row execute function public.handle_submission_review();

-- ─── Row Level Security ──────────────────────────────────────────────────────

alter table public.profiles enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.challenges enable row level security;
alter table public.submissions enable row level security;
alter table public.chat_messages enable row level security;
alter table public.notifications enable row level security;
alter table public.blocked_users enable row level security;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.is_admin from public.profiles p where p.id = auth.uid()),
    false
  );
$$;

-- Profiles
create policy "Profiles are viewable by authenticated users"
  on public.profiles for select to authenticated using (true);

create policy "Users update own profile"
  on public.profiles for update to authenticated
  using (auth.uid() = id) with check (auth.uid() = id);

-- Challenges (read-only catalog for users)
create policy "Active challenges are public to authenticated users"
  on public.challenges for select to authenticated
  using (is_active = true);

create policy "Admins manage challenges"
  on public.challenges for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- Groups
create policy "Members can view their groups"
  on public.groups for select to authenticated
  using (
    exists (
      select 1 from public.group_members gm
      where gm.group_id = groups.id and gm.user_id = auth.uid()
    )
  );

create policy "Authenticated users can create groups"
  on public.groups for insert to authenticated
  with check (auth.uid() = created_by);

-- Group members
create policy "Members can view group membership"
  on public.group_members for select to authenticated
  using (
    exists (
      select 1 from public.group_members gm
      where gm.group_id = group_members.group_id and gm.user_id = auth.uid()
    )
  );

create policy "Users can join groups"
  on public.group_members for insert to authenticated
  with check (auth.uid() = user_id);

-- Submissions
create policy "Users read own submissions"
  on public.submissions for select to authenticated
  using (auth.uid() = user_id or public.is_admin());

create policy "Users create own submissions"
  on public.submissions for insert to authenticated
  with check (auth.uid() = user_id and status = 'pending');

create policy "Admins review submissions"
  on public.submissions for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- Chat
create policy "Group members read chat"
  on public.chat_messages for select to authenticated
  using (
    exists (
      select 1 from public.group_members gm
      where gm.group_id = chat_messages.group_id and gm.user_id = auth.uid()
    )
  );

create policy "Group members send chat"
  on public.chat_messages for insert to authenticated
  with check (
    auth.uid() = user_id and
    exists (
      select 1 from public.group_members gm
      where gm.group_id = chat_messages.group_id and gm.user_id = auth.uid()
    )
  );

-- Notifications
create policy "Users read own notifications"
  on public.notifications for select to authenticated
  using (auth.uid() = user_id);

create policy "Users update own notifications"
  on public.notifications for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Blocked users
create policy "Users manage own blocks"
  on public.blocked_users for all to authenticated
  using (auth.uid() = blocker_id) with check (auth.uid() = blocker_id);

-- ─── Storage: proof photos ─────────────────────────────────────────────────────

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'proofs',
  'proofs',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'image/heic', 'image/webp']
)
on conflict (id) do nothing;

create policy "Users upload own proof photos"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'proofs'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users read own proof photos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'proofs'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_admin()
    )
  );

-- ─── Leaderboard helper view ───────────────────────────────────────────────────

create or replace view public.friends_leaderboard as
select
  gm.group_id,
  p.id as user_id,
  p.display_name,
  p.handle,
  p.avatar_emoji,
  p.total_points,
  rank() over (partition by gm.group_id order by p.total_points desc) as rank
from public.group_members gm
join public.profiles p on p.id = gm.user_id;

grant select on public.friends_leaderboard to authenticated;
