-- Swift UUID.uuidString is uppercase; auth.uid()::text is lowercase.

drop policy if exists "Users upload own proof photos" on storage.objects;
create policy "Users upload own proof photos"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'proofs'
    and lower((storage.foldername(name))[1]) = lower(auth.uid()::text)
  );

drop policy if exists "Users read own proof photos" on storage.objects;
create policy "Users read own proof photos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'proofs'
    and (
      lower((storage.foldername(name))[1]) = lower(auth.uid()::text)
      or public.is_admin()
    )
  );

drop policy if exists "Users update own proof photos" on storage.objects;
create policy "Users update own proof photos"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'proofs'
    and lower((storage.foldername(name))[1]) = lower(auth.uid()::text)
  )
  with check (
    bucket_id = 'proofs'
    and lower((storage.foldername(name))[1]) = lower(auth.uid()::text)
  );
