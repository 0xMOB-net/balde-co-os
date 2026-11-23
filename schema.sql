-- Balde & Co OS V5 : exécuter dans Supabase SQL Editor, une seule fois.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null default '',
 role text not null default 'client' check(role in ('client','agent','admin')),
 created_at timestamptz not null default now()
);
create table if not exists public.cases (
 id uuid primary key default gen_random_uuid(),
 client_id uuid not null references public.profiles(id),
 assigned_to uuid references public.profiles(id),
 kind text not null check(kind in ('etudes','voyage','visa','autre')),
 title text not null check(length(title) between 3 and 180),
 destination text not null default '',
 status text not null default 'nouveau' check(status in ('nouveau','en_cours','en_attente','termine','annule')),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.messages (
 id uuid primary key default gen_random_uuid(),
 case_id uuid not null references public.cases(id) on delete cascade,
 sender_id uuid not null references public.profiles(id),
 body text not null check(length(body) between 1 and 5000),
 internal boolean not null default false,
 created_at timestamptz not null default now()
);
create table if not exists public.tasks (
 id uuid primary key default gen_random_uuid(),
 case_id uuid not null references public.cases(id) on delete cascade,
 title text not null,
 due_date date,
 completed boolean not null default false,
 created_at timestamptz not null default now()
);
create table if not exists public.payments (
 id uuid primary key default gen_random_uuid(),
 case_id uuid not null references public.cases(id) on delete cascade,
 amount numeric(14,2) not null check(amount >= 0),
 currency text not null default 'GNF' check(currency in ('GNF','EUR','USD','CAD','CNY')),
 note text not null default '',
 created_at timestamptz not null default now()
);
create or replace function public.my_role() returns text language sql stable security definer set search_path = '' as $$
 select role from public.profiles where id = (select auth.uid())
$$;
create or replace function public.is_staff() returns boolean language sql stable security definer set search_path = '' as $$
 select coalesce((select role in ('admin','agent') from public.profiles where id = (select auth.uid())),false)
$$;
create or replace function public.can_access_case(cid uuid) returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.cases c where c.id=cid and
 (c.client_id=(select auth.uid()) or (select public.my_role())='admin' or
 (c.assigned_to=(select auth.uid()) and (select public.is_staff()))))
$$;
create or replace function public.can_manage_case(cid uuid) returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.cases c where c.id=cid and
 ((select public.my_role())='admin' or (c.assigned_to=(select auth.uid()) and (select public.is_staff()))))
$$;
create or replace function public.new_profile() returns trigger language plpgsql security definer set search_path = '' as $$
 begin insert into public.profiles(id,full_name,role) values(new.id,coalesce(new.raw_user_meta_data->>'full_name',''),'client'); return new; end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.new_profile();
-- No client may change their own role.
create or replace function public.guard_profile_role() returns trigger language plpgsql set search_path = '' as $$
 begin if new.role is distinct from old.role then raise exception 'Role changes are admin-only'; end if; return new; end;
$$;
drop trigger if exists prevent_role_change on public.profiles;
create trigger prevent_role_change before update on public.profiles for each row execute function public.guard_profile_role();
-- Ensure only staff can set workflow/assignment; clients can create their own cases only.
create or replace function public.guard_case() returns trigger language plpgsql security definer set search_path = '' as $$
 begin
 if tg_op='INSERT' then
  if (select public.my_role())='client' then
   if new.client_id is distinct from (select auth.uid()) or new.assigned_to is not null or new.status <> 'nouveau' then raise exception 'Invalid client case'; end if;
  end if;
 else
  if new.client_id is distinct from old.client_id then raise exception 'Client cannot be changed'; end if;
 end if;
 new.updated_at=now(); return new;
 end;
$$;
drop trigger if exists validate_case on public.cases;
create trigger validate_case before insert or update on public.cases for each row execute function public.guard_case();
create or replace function public.guard_message() returns trigger language plpgsql security definer set search_path = '' as $$
 begin
 if new.sender_id is distinct from (select auth.uid()) then raise exception 'Invalid sender'; end if;
 if new.internal and not (select public.is_staff()) then raise exception 'Internal messages restricted'; end if;
 return new;
 end;
$$;
drop trigger if exists validate_message on public.messages;
create trigger validate_message before insert on public.messages for each row execute function public.guard_message();
alter table public.profiles enable row level security;
alter table public.cases enable row level security;
alter table public.messages enable row level security;
alter table public.tasks enable row level security;
alter table public.payments enable row level security;
drop policy if exists profiles_read on public.profiles;
create policy profiles_read on public.profiles for select to authenticated using(id=(select auth.uid()) or (select public.is_staff()));
drop policy if exists profiles_update on public.profiles;
create policy profiles_update on public.profiles for update to authenticated using(id=(select auth.uid())) with check(id=(select auth.uid()));
drop policy if exists cases_read on public.cases;
create policy cases_read on public.cases for select to authenticated using((select public.can_access_case(id)));
drop policy if exists cases_insert on public.cases;
create policy cases_insert on public.cases for insert to authenticated with check(client_id=(select auth.uid()) or (select public.is_staff()));
drop policy if exists cases_update on public.cases;
create policy cases_update on public.cases for update to authenticated using((select public.can_manage_case(id))) with check((select public.can_manage_case(id)));
drop policy if exists messages_read on public.messages;
create policy messages_read on public.messages for select to authenticated using((select public.can_access_case(case_id)) and (not internal or (select public.is_staff())));
drop policy if exists messages_insert on public.messages;
create policy messages_insert on public.messages for insert to authenticated with check(sender_id=(select auth.uid()) and (select public.can_access_case(case_id)) and (not internal or (select public.is_staff())));
drop policy if exists tasks_read on public.tasks;
create policy tasks_read on public.tasks for select to authenticated using((select public.can_access_case(case_id)));
drop policy if exists tasks_write on public.tasks;
create policy tasks_write on public.tasks for all to authenticated using((select public.can_manage_case(case_id))) with check((select public.can_manage_case(case_id)));
drop policy if exists payments_read on public.payments;
create policy payments_read on public.payments for select to authenticated using((select public.can_access_case(case_id)));
drop policy if exists payments_write on public.payments;
create policy payments_write on public.payments for all to authenticated using((select public.can_manage_case(case_id))) with check((select public.can_manage_case(case_id)));
-- Staff access is granted manually by project owner in SQL Editor, never through client signup.
-- After signing up, to promote YOUR account (replace email):
-- update public.profiles set role='admin' where id=(select id from auth.users where email='YOUR_EMAIL');
-- The trigger above blocks this update: use the dedicated SQL Editor transaction below instead:
-- begin; alter table public.profiles disable trigger prevent_role_change;
-- update public.profiles set role='admin' where id=(select id from auth.users where email='YOUR_EMAIL');
-- alter table public.profiles enable trigger prevent_role_change; commit;
