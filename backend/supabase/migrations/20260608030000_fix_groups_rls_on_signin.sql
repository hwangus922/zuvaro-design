-- Allow creators to read groups before membership row exists, and provide
-- a security-definer helper for first-time group setup during sign-in.

drop policy if exists "Members can view their groups" on public.groups;
create policy "Members can view their groups"
  on public.groups for select to authenticated
  using (created_by = auth.uid() or public.is_group_member(id));

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

  select g.*
  into existing_group
  from public.groups g
  join public.group_members gm on gm.group_id = g.id
  where gm.user_id = uid
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
