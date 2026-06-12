-- Phone verification, contact discovery, and SMS notification preferences.

alter table public.profiles
  add column if not exists phone_e164 text,
  add column if not exists phone_verified boolean not null default false,
  add column if not exists phone_discoverable boolean not null default false,
  add column if not exists sms_notifications_enabled boolean not null default false;

create unique index if not exists profiles_phone_e164_unique_idx
  on public.profiles (phone_e164)
  where phone_e164 is not null;

create table if not exists public.phone_otp_codes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  phone_e164 text not null,
  code text not null check (char_length(code) = 6),
  expires_at timestamptz not null,
  consumed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists phone_otp_codes_user_idx
  on public.phone_otp_codes (user_id, created_at desc);

create table if not exists public.sms_outbox (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  phone_e164 text not null,
  body text not null,
  status text not null default 'pending' check (status in ('pending', 'sent', 'failed')),
  created_at timestamptz not null default now(),
  sent_at timestamptz
);

create index if not exists sms_outbox_status_idx
  on public.sms_outbox (status, created_at);

alter table public.phone_otp_codes enable row level security;
alter table public.sms_outbox enable row level security;

create policy "Users read own OTP rows"
  on public.phone_otp_codes for select to authenticated
  using (user_id = auth.uid());

create policy "Users read own SMS outbox"
  on public.sms_outbox for select to authenticated
  using (user_id = auth.uid() or public.is_admin());

create or replace function public.normalize_phone_e164(p_raw text)
returns text
language plpgsql
immutable
as $$
declare
  digits text;
begin
  digits := regexp_replace(coalesce(p_raw, ''), '[^0-9+]', '', 'g');
  if digits = '' then
    return null;
  end if;
  if digits like '+%' then
    digits := '+' || regexp_replace(substring(digits from 2), '[^0-9]', '', 'g');
  else
    digits := regexp_replace(digits, '[^0-9]', '', 'g');
    if char_length(digits) = 10 then
      digits := '+1' || digits;
    elsif char_length(digits) = 11 and digits like '1%' then
      digits := '+' || digits;
    else
      digits := '+' || digits;
    end if;
  end if;
  if char_length(digits) < 8 or char_length(digits) > 16 then
    return null;
  end if;
  return digits;
end;
$$;

create or replace function public.protect_profile_phone_fields()
returns trigger
language plpgsql
as $$
begin
  if current_setting('zuvaro.phone_rpc', true) is distinct from 'true' then
    new.phone_e164 := old.phone_e164;
    new.phone_verified := old.phone_verified;
  end if;
  if new.sms_notifications_enabled and not coalesce(new.phone_verified, false) then
    new.sms_notifications_enabled := false;
  end if;
  return new;
end;
$$;

drop trigger if exists protect_profile_phone_fields on public.profiles;
create trigger protect_profile_phone_fields
  before update on public.profiles
  for each row execute function public.protect_profile_phone_fields();

create or replace function public.request_phone_verification(p_phone text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  normalized text;
  otp_code text;
  recent_count integer;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  normalized := public.normalize_phone_e164(p_phone);
  if normalized is null then
    raise exception 'Invalid phone number';
  end if;

  if exists (
    select 1 from public.profiles
    where phone_e164 = normalized and phone_verified = true and id <> uid
  ) then
    raise exception 'Phone number already linked to another account';
  end if;

  select count(*)::integer into recent_count
  from public.phone_otp_codes
  where user_id = uid and created_at > now() - interval '1 hour';

  if recent_count >= 5 then
    raise exception 'Too many verification attempts. Try again later.';
  end if;

  otp_code := lpad((floor(random() * 1000000))::int::text, 6, '0');

  insert into public.phone_otp_codes (user_id, phone_e164, code, expires_at)
  values (uid, normalized, otp_code, now() + interval '10 minutes');

  perform set_config('zuvaro.phone_rpc', 'true', true);
  update public.profiles
  set phone_e164 = normalized, phone_verified = false, updated_at = now()
  where id = uid;

  insert into public.sms_outbox (user_id, phone_e164, body)
  values (uid, normalized, 'Your Zuvaro verification code is ' || otp_code || '. It expires in 10 minutes.');

  return jsonb_build_object(
    'phone_e164', normalized,
    'expires_in_seconds', 600,
    'delivery', 'queued'
  );
end;
$$;

create or replace function public.verify_phone_code(p_code text)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  otp_row public.phone_otp_codes;
  updated_profile public.profiles;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select * into otp_row
  from public.phone_otp_codes
  where user_id = uid
    and consumed_at is null
    and expires_at > now()
  order by created_at desc
  limit 1;

  if otp_row.id is null then
    raise exception 'No active verification code. Request a new one.';
  end if;

  if trim(p_code) <> otp_row.code then
    raise exception 'Invalid verification code';
  end if;

  update public.phone_otp_codes
  set consumed_at = now()
  where id = otp_row.id;

  perform set_config('zuvaro.phone_rpc', 'true', true);
  update public.profiles
  set phone_verified = true, updated_at = now()
  where id = uid
  returning * into updated_profile;

  return updated_profile;
end;
$$;

create or replace function public.set_phone_preferences(
  p_discoverable boolean,
  p_sms_enabled boolean
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  updated_profile public.profiles;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  if p_sms_enabled then
    if not exists (
      select 1 from public.profiles where id = uid and phone_verified = true and phone_e164 is not null
    ) then
      raise exception 'Verify your phone number before enabling SMS updates';
    end if;
  end if;

  update public.profiles
  set
    phone_discoverable = coalesce(p_discoverable, phone_discoverable),
    sms_notifications_enabled = coalesce(p_sms_enabled, sms_notifications_enabled),
    updated_at = now()
  where id = uid
  returning * into updated_profile;

  return updated_profile;
end;
$$;

create or replace function public.find_friends_by_phones(p_phones text[])
returns table (
  user_id uuid,
  display_name text,
  handle text,
  avatar_emoji text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  normalized_phones text[];
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select coalesce(array_agg(distinct public.normalize_phone_e164(p)), '{}')
  into normalized_phones
  from unnest(coalesce(p_phones, '{}')) as p
  where public.normalize_phone_e164(p) is not null;

  if coalesce(array_length(normalized_phones, 1), 0) = 0 then
    return;
  end if;

  if coalesce(array_length(normalized_phones, 1), 0) > 500 then
    raise exception 'Too many phone numbers in one request';
  end if;

  return query
  select p.id, p.display_name, p.handle, p.avatar_emoji
  from public.profiles p
  where p.id <> uid
    and p.phone_verified = true
    and p.phone_discoverable = true
    and p.phone_e164 = any(normalized_phones);
end;
$$;

grant execute on function public.normalize_phone_e164(text) to authenticated;
grant execute on function public.request_phone_verification(text) to authenticated;
grant execute on function public.verify_phone_code(text) to authenticated;
grant execute on function public.set_phone_preferences(boolean, boolean) to authenticated;
create or replace function public.remove_phone_number()
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  updated_profile public.profiles;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  perform set_config('zuvaro.phone_rpc', 'true', true);
  update public.profiles
  set
    phone_e164 = null,
    phone_verified = false,
    phone_discoverable = false,
    sms_notifications_enabled = false,
    updated_at = now()
  where id = uid
  returning * into updated_profile;

  return updated_profile;
end;
$$;

grant execute on function public.remove_phone_number() to authenticated;
grant execute on function public.find_friends_by_phones(text[]) to authenticated;
