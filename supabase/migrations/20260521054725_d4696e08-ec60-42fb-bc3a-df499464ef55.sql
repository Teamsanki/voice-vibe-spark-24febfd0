insert into storage.buckets (id, name, public) values ('voice', 'voice', true) on conflict (id) do nothing;

create policy "Voice public read" on storage.objects for select using (bucket_id = 'voice');
create policy "Voice anyone upload" on storage.objects for insert with check (bucket_id = 'voice');
create policy "Voice owner delete" on storage.objects for delete using (bucket_id = 'voice');