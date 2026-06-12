-- Username customization: onboarding flag + validated set/check RPCs.

alter table public.profiles
  add column if not exists username_customized boolean not null default false;

-- Existing accounts keep their current handle without forced onboarding.
update public.profiles
set username_customized = true
where username_customized = false;

create or replace function public.normalize_username(p_username text)
returns text
language sql
immutable
as $$
  select lower(
    regexp_replace(
      trim(both '@' from coalesce(p_username, '')),
      '[^a-z0-9_]',
      '',
      'g'
    )
  );
$$;

create or replace function public.check_username_available(p_username text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_clean text := public.normalize_username(p_username);
  v_handle text;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if length(v_clean) < 3 or length(v_clean) > 20 then
    return false;
  end if;

  if v_clean !~ '^[a-z0-9]' then
    return false;
  end if;

  v_handle := '@' || v_clean;

  return not exists (
    select 1
    from public.profiles p
    where lower(p.handle) = v_handle
      and p.id <> v_user_id
  );
end;
$$;

create or replace function public.set_username(p_username text)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_clean text := public.normalize_username(p_username);
  v_handle text;
  v_profile public.profiles;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if length(v_clean) < 3 then
    raise exception 'Username must be at least 3 characters.';
  end if;

  if length(v_clean) > 20 then
    raise exception 'Username must be 20 characters or less.';
  end if;

  if v_clean !~ '^[a-z0-9]' then
    raise exception 'Username must start with a letter or number.';
  end if;

  v_handle := '@' || v_clean;

  if exists (
    select 1
    from public.profiles p
    where lower(p.handle) = v_handle
      and p.id <> v_user_id
  ) then
    raise exception 'That username is already taken.';
  end if;

  update public.profiles
  set handle = v_handle,
      username_customized = true
  where id = v_user_id
  returning * into v_profile;

  if v_profile.id is null then
    raise exception 'Profile not found.';
  end if;

  return v_profile;
end;
$$;

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

  insert into public.profiles (id, display_name, handle, username_customized)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', 'Zuvaro Player'),
    final_handle || substr(replace(new.id::text, '-', ''), 1, 4),
    false
  );

  return new;
end;
$$;

grant execute on function public.normalize_username(text) to authenticated;
grant execute on function public.check_username_available(text) to authenticated;
grant execute on function public.set_username(text) to authenticated;
