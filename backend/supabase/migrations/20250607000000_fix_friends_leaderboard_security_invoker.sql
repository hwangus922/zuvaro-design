-- Supabase linter: views must use security_invoker so RLS applies as the querying user.

create or replace view public.friends_leaderboard
with (security_invoker = true)
as
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
