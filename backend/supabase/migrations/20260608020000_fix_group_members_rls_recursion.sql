-- Fix infinite recursion: group_members policies must not self-query under RLS.

create or replace function public.is_group_member(check_group_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.group_members gm
    where gm.group_id = check_group_id
      and gm.user_id = auth.uid()
  );
$$;

grant execute on function public.is_group_member(uuid) to authenticated;

drop policy if exists "Members can view their groups" on public.groups;
create policy "Members can view their groups"
  on public.groups for select to authenticated
  using (public.is_group_member(id));

drop policy if exists "Members can view group membership" on public.group_members;
create policy "Members can view group membership"
  on public.group_members for select to authenticated
  using (public.is_group_member(group_id));

drop policy if exists "Group members read chat" on public.chat_messages;
create policy "Group members read chat"
  on public.chat_messages for select to authenticated
  using (public.is_group_member(group_id));

drop policy if exists "Group members send chat" on public.chat_messages;
create policy "Group members send chat"
  on public.chat_messages for insert to authenticated
  with check (
    auth.uid() = user_id
    and public.is_group_member(group_id)
  );

drop policy if exists "Members can create custom challenges" on public.custom_challenges;
create policy "Members can create custom challenges"
  on public.custom_challenges for insert to authenticated
  with check (
    created_by = auth.uid()
    and public.is_group_member(group_id)
  );

drop policy if exists "Members can view custom challenges in own groups" on public.custom_challenges;
create policy "Members can view custom challenges in own groups"
  on public.custom_challenges for select to authenticated
  using (public.is_group_member(group_id));
