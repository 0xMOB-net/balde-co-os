-- Execute AFTER schema.sql from V5. Safe to re-run.
create table if not exists public.case_documents (
 id uuid primary key default gen_random_uuid(),
 case_id uuid not null references public.cases(id) on delete cascade,
 uploaded_by uuid not null references public.profiles(id),
 file_name text not null check(length(file_name) between 1 and 255),
 storage_path text not null unique,
 created_at timestamptz not null default now()
);
alter table public.case_documents enable row level security;
drop policy if exists documents_select on public.case_documents;
create policy documents_select on public.case_documents for select to authenticated using(public.can_access_case(case_id));
drop policy if exists documents_insert on public.case_documents;
create policy documents_insert on public.case_documents for insert to authenticated
 with check(uploaded_by=auth.uid() and public.can_access_case(case_id) and split_part(storage_path,'/',1)=case_id::text);
-- Private bucket, file size limit and accepted formats.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('case-documents','case-documents',false,10485760,array['application/pdf','image/jpeg','image/png'])
on conflict(id) do update set public=false,file_size_limit=10485760,allowed_mime_types=excluded.allowed_mime_types;
drop policy if exists case_files_read on storage.objects;
create policy case_files_read on storage.objects for select to authenticated
using(bucket_id='case-documents' and public.can_access_case((split_part(name,'/',1))::uuid));
drop policy if exists case_files_upload on storage.objects;
create policy case_files_upload on storage.objects for insert to authenticated
with check(bucket_id='case-documents' and public.can_access_case((split_part(name,'/',1))::uuid));
-- Do not allow user-initiated overwrite/delete of private documents.
-- Realtime must still be enabled separately in Dashboard > Database > Publications.
