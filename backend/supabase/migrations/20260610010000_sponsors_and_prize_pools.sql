-- Brand sponsors fund prize pools; top 5 in each regional board split the pool.

create table public.sponsors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  tagline text,
  logo_emoji text not null default '🏢',
  website_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.challenges
  add column if not exists sponsor_id uuid references public.sponsors (id) on delete set null;

create index if not exists challenges_sponsor_idx on public.challenges (sponsor_id)
  where sponsor_id is not null;

create table public.prize_pools (
  id uuid primary key default gen_random_uuid(),
  region_id uuid not null references public.regions (id) on delete cascade,
  title text not null default 'Weekly prize pool',
  total_cents integer not null check (total_cents > 0),
  currency text not null default 'usd',
  period_start timestamptz not null,
  period_end timestamptz not null,
  status text not null default 'active' check (status in ('active', 'closed', 'paid')),
  created_at timestamptz not null default now(),
  check (period_end > period_start)
);

create index prize_pools_region_status_idx on public.prize_pools (region_id, status, period_end desc);

create table public.prize_payouts (
  id uuid primary key default gen_random_uuid(),
  pool_id uuid not null references public.prize_pools (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  rank integer not null check (rank between 1 and 5),
  amount_cents integer not null check (amount_cents > 0),
  status text not null default 'pending' check (status in ('pending', 'paid', 'failed')),
  paid_at timestamptz,
  created_at timestamptz not null default now(),
  unique (pool_id, rank),
  unique (pool_id, user_id)
);

create index prize_payouts_user_idx on public.prize_payouts (user_id, created_at desc);

alter table public.sponsors enable row level security;
alter table public.prize_pools enable row level security;
alter table public.prize_payouts enable row level security;

create policy "Authenticated users read active sponsors"
  on public.sponsors for select to authenticated
  using (is_active = true);

create policy "Admins manage sponsors"
  on public.sponsors for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "Authenticated users read prize pools"
  on public.prize_pools for select to authenticated
  using (true);

create policy "Admins manage prize pools"
  on public.prize_pools for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "Users read own prize payouts"
  on public.prize_payouts for select to authenticated
  using (auth.uid() = user_id or public.is_admin());

create policy "Admins manage prize payouts"
  on public.prize_payouts for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- Seed sponsors (idempotent)
insert into public.sponsors (id, name, tagline, logo_emoji, website_url) values
  ('00000000-0000-0000-0000-000000000101', 'Pulse Energy', 'Fuel missions outside', '⚡', 'https://example.com/pulse'),
  ('00000000-0000-0000-0000-000000000102', 'Swift Sip Coffee', 'Show up caffeinated', '☕', 'https://example.com/swiftsip'),
  ('00000000-0000-0000-0000-000000000103', 'Trailhead Co.', 'Gear for real-world dares', '🥾', 'https://example.com/trailhead')
on conflict (id) do nothing;

-- Link a few catalog challenges to sponsors
update public.challenges
set sponsor_id = '00000000-0000-0000-0000-000000000103'
where id = '00000000-0000-0000-0000-000000000003';

update public.challenges
set sponsor_id = '00000000-0000-0000-0000-000000000102'
where id = '00000000-0000-0000-0000-000000000004';

update public.challenges
set sponsor_id = '00000000-0000-0000-0000-000000000101'
where id = '00000000-0000-0000-0000-000000000008';

-- Active weekly pools per US region (example totals)
insert into public.prize_pools (region_id, title, total_cents, period_start, period_end, status)
select
  r.id,
  r.name || ' weekly pool',
  case r.code
    when 'us-west' then 75000
    when 'us-northeast' then 60000
    when 'us-southeast' then 50000
    when 'us-midwest' then 45000
    when 'us-southwest' then 55000
    else 40000
  end,
  date_trunc('week', now()),
  date_trunc('week', now()) + interval '7 days',
  'active'
from public.regions r
where r.kind = 'us_region'
  and not exists (
    select 1
    from public.prize_pools pp
    where pp.region_id = r.id
      and pp.status = 'active'
      and pp.period_end > now()
  );
