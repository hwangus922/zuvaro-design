-- Product analytics events (privacy-respecting, no PII in properties).

create table public.analytics_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete set null,
  event_name text not null check (char_length(trim(event_name)) > 0),
  properties jsonb not null default '{}'::jsonb,
  session_id text,
  created_at timestamptz not null default now()
);

create index analytics_events_name_idx on public.analytics_events (event_name, created_at desc);
create index analytics_events_user_idx on public.analytics_events (user_id, created_at desc)
  where user_id is not null;
create index analytics_events_session_idx on public.analytics_events (session_id, created_at desc)
  where session_id is not null;

alter table public.analytics_events enable row level security;

create policy "Authenticated users insert own analytics events"
  on public.analytics_events for insert to authenticated
  with check (user_id is null or user_id = auth.uid());

create policy "Anonymous analytics inserts"
  on public.analytics_events for insert to anon
  with check (user_id is null);

create policy "Admins read analytics events"
  on public.analytics_events for select to authenticated
  using (public.is_admin());
