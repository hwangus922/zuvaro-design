-- App Store compliance: real account deletion, content reporting metadata.

alter table public.user_reports
  add column if not exists reported_user_id uuid references public.profiles (id) on delete set null,
  add column if not exists reported_message_id uuid references public.chat_messages (id) on delete set null;

create index if not exists user_reports_reported_user_idx
  on public.user_reports (reported_user_id, created_at desc);

-- Replace queue-only deletion with immediate account + data removal.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, storage, auth
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  delete from storage.objects
  where bucket_id = 'proofs'
    and lower((storage.foldername(name))[1]) = lower(v_user_id::text);

  update public.account_deletion_requests
  set status = 'processed', requested_at = now()
  where user_id = v_user_id;

  insert into public.account_deletion_requests (user_id, requested_at, status)
  values (v_user_id, now(), 'processed')
  on conflict (user_id)
  do update set status = 'processed', requested_at = excluded.requested_at;

  delete from auth.users where id = v_user_id;
end;
$$;

-- Keep legacy RPC name but route to real deletion.
create or replace function public.request_account_deletion(target_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if target_user_id <> auth.uid() then
    raise exception 'Can only delete your own account';
  end if;

  perform public.delete_my_account();
end;
$$;

grant execute on function public.delete_my_account() to authenticated;
grant execute on function public.request_account_deletion(uuid) to authenticated;
