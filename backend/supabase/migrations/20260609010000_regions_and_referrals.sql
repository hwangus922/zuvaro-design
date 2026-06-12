-- Regional onboarding pools + referral bonus (50pts at 5 invites).

create table public.regions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  kind text not null check (kind in ('us_region', 'country')),
  sort_order integer not null default 0
);

insert into public.regions (code, name, kind, sort_order) values
  ('us-northeast', 'Northeast', 'us_region', 1),
  ('us-southeast', 'Southeast', 'us_region', 2),
  ('us-midwest', 'Midwest', 'us_region', 3),
  ('us-southwest', 'Southwest', 'us_region', 4),
  ('us-west', 'West', 'us_region', 5),
  ('country-ca', 'Canada', 'country', 10),
  ('country-gb', 'United Kingdom', 'country', 11),
  ('country-au', 'Australia', 'country', 12),
  ('country-mx', 'Mexico', 'country', 13),
  ('country-in', 'India', 'country', 14),
  ('country-br', 'Brazil', 'country', 15),
  ('country-de', 'Germany', 'country', 16),
  ('country-fr', 'France', 'country', 17),
  ('country-other', 'Other country', 'country', 99)
on conflict (code) do nothing;

alter table public.profiles
  add column if not exists region_id uuid references public.regions (id) on delete set null,
  add column if not exists referral_count integer not null default 0 check (referral_count >= 0),
  add column if not exists referral_bonus_claimed boolean not null default false;

create index if not exists profiles_region_idx on public.profiles (region_id);

alter table public.groups
  add column if not exists region_id uuid references public.regions (id) on delete set null,
  add column if not exists kind text not null default 'crew' check (kind in ('crew', 'region'));

create index if not exists groups_region_kind_idx on public.groups (region_id, kind);

create table public.referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_id uuid not null references public.profiles (id) on delete cascade,
  referred_id uuid not null unique references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  check (referrer_id <> referred_id)
);

create index referrals_referrer_idx on public.referrals (referrer_id, created_at desc);

alter table public.regions enable row level security;
alter table public.referrals enable row level security;

create policy "Anyone can read regions"
  on public.regions for select to authenticated
  using (true);

create policy "Users read referrals they made"
  on public.referrals for select to authenticated
  using (auth.uid() = referrer_id);

create or replace function public.process_referral(p_referrer_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  referral_total integer;
  bonus_claimed boolean;
begin
  select count(*)::integer
  into referral_total
  from public.referrals
  where referrer_id = p_referrer_id;

  update public.profiles
  set
    referral_count = referral_total,
    updated_at = now()
  where id = p_referrer_id
  returning referral_bonus_claimed into bonus_claimed;

  if referral_total >= 5 and not coalesce(bonus_claimed, false) then
    update public.profiles
    set
      total_points = total_points + 50,
      referral_bonus_claimed = true,
      updated_at = now()
    where id = p_referrer_id;

    insert into public.notifications (user_id, title, body, kind)
    values (
      p_referrer_id,
      'Referral bonus unlocked',
      '+50pts for inviting 5 friends',
      'friend'
    );
  end if;
end;
$$;

create or replace function public.set_user_region(p_region_code text)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  target_region public.regions;
  region_group public.groups;
  updated_profile public.profiles;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select * into target_region
  from public.regions
  where code = lower(trim(p_region_code))
  limit 1;

  if not found then
    raise exception 'Invalid region';
  end if;

  update public.profiles
  set region_id = target_region.id, updated_at = now()
  where id = uid
  returning * into updated_profile;

  select * into region_group
  from public.groups
  where region_id = target_region.id and kind = 'region'
  limit 1;

  if not found then
    insert into public.groups (name, created_by, region_id, kind)
    values (target_region.name, uid, target_region.id, 'region')
    returning * into region_group;
  end if;

  insert into public.group_members (group_id, user_id, role)
  values (region_group.id, uid, 'member')
  on conflict do nothing;

  return updated_profile;
end;
$$;

grant execute on function public.set_user_region(text) to authenticated;

create or replace function public.join_group_by_invite(p_invite_code text)
returns public.groups
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  target public.groups;
  inserted_count integer;
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

  if target.kind = 'crew'
     and target.created_by is not null
     and target.created_by <> uid then
    insert into public.referrals (referrer_id, referred_id)
    values (target.created_by, uid)
    on conflict (referred_id) do nothing;

    get diagnostics inserted_count = row_count;
    if inserted_count > 0 then
      perform public.process_referral(target.created_by);
    end if;
  end if;

  return target;
end;
$$;

create or replace view public.regional_leaderboard
with (security_invoker = true)
as
select
  p.region_id,
  p.id as user_id,
  p.display_name,
  p.handle,
  p.avatar_emoji,
  p.total_points,
  rank() over (partition by p.region_id order by p.total_points desc) as rank
from public.profiles p
where p.region_id is not null;

grant select on public.regional_leaderboard to authenticated;
