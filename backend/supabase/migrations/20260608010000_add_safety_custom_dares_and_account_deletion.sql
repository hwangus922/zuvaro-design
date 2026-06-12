-- Custom dares, support reports, and account deletion requests.

create table public.custom_challenges (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  created_by uuid not null references public.profiles (id) on delete cascade,
  text text not null check (char_length(trim(text)) >= 4),
  points integer not null default 20 check (points between 0 and 60),
  created_at timestamptz not null default now()
);

create index custom_challenges_group_idx on public.custom_challenges (group_id, created_at desc);

create table public.user_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  report_type text not null default 'support',
  details text not null check (char_length(trim(details)) >= 10),
  created_at timestamptz not null default now()
);

create index user_reports_reporter_idx on public.user_reports (reporter_id, created_at desc);

create table public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  requested_at timestamptz not null default now(),
  status text not null default 'pending' check (status in ('pending', 'processed'))
);

alter table public.custom_challenges enable row level security;
alter table public.user_reports enable row level security;
alter table public.account_deletion_requests enable row level security;

create policy "Members can create custom challenges"
  on public.custom_challenges for insert to authenticated
  with check (
    created_by = auth.uid()
    and exists (
      select 1 from public.group_members gm
      where gm.group_id = custom_challenges.group_id and gm.user_id = auth.uid()
    )
  );

create policy "Members can view custom challenges in own groups"
  on public.custom_challenges for select to authenticated
  using (
    exists (
      select 1 from public.group_members gm
      where gm.group_id = custom_challenges.group_id and gm.user_id = auth.uid()
    )
  );

create policy "Users create own support reports"
  on public.user_reports for insert to authenticated
  with check (reporter_id = auth.uid());

create policy "Users view own support reports"
  on public.user_reports for select to authenticated
  using (reporter_id = auth.uid());

create policy "Users can view own account deletion request"
  on public.account_deletion_requests for select to authenticated
  using (user_id = auth.uid());

create or replace function public.request_account_deletion(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if target_user_id <> auth.uid() then
    raise exception 'Can only request deletion for your own account';
  end if;

  insert into public.account_deletion_requests (user_id, requested_at, status)
  values (target_user_id, now(), 'pending')
  on conflict (user_id)
  do update set requested_at = excluded.requested_at, status = 'pending';
end;
$$;

grant execute on function public.request_account_deletion(uuid) to authenticated;
