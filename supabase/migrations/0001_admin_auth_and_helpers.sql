-- Milestone 1: Admin authorization table, helper predicate, and profile RPC.
-- Enforces strict server-side admin access; never trusts editable user_metadata.

create extension if not exists pgcrypto;

-- Shared updated_at trigger helper used across M1-M5 tables.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  display_name text not null,
  role text not null default 'editor'
    check (role in ('super_admin', 'editor', 'reviewer')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_admin_users_updated_at on public.admin_users;
create trigger trg_admin_users_updated_at
  before update on public.admin_users
  for each row execute function public.touch_updated_at();

alter table public.admin_users enable row level security;

-- Authoritative admin predicate used by all RLS policies and SECURITY DEFINER RPCs.
-- Uses cached scalar subquery (select auth.uid()) and checks active status.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select
    (select auth.uid()) is not null
    and (
      exists (
        select 1
        from public.admin_users au
        where au.user_id = (select auth.uid())
          and au.is_active = true
      )
      or (
        coalesce((select auth.jwt()) -> 'app_metadata' ->> 'role', '') = 'admin'
        and not exists (
          select 1
          from public.admin_users au
          where au.user_id = (select auth.uid())
            and au.is_active = false
        )
      )
    );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

drop policy if exists admin_users_select_self_or_admin on public.admin_users;
create policy admin_users_select_self_or_admin
  on public.admin_users
  for select
  to authenticated
  using (
    user_id = (select auth.uid())
    or public.is_admin()
  );

-- Note: No INSERT/UPDATE/DELETE policies are granted to `authenticated`.
-- Admin rows must be provisioned/revoked via SQL migrations or Supabase Studio.

-- RPC called by ChapterNo Admin Dashboard after login and session restore.
-- Returns the caller's admin profile or raises 42501 for non-admin / inactive accounts.
create or replace function public.get_admin_profile()
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid := (select auth.uid());
  v_row public.admin_users%rowtype;
  v_jwt jsonb := (select auth.jwt());
begin
  if v_uid is null or not public.is_admin() then
    raise exception 'Admin privileges required.'
      using errcode = '42501';
  end if;

  select *
  into v_row
  from public.admin_users au
  where au.user_id = v_uid;

  if found then
    return jsonb_build_object(
      'user_id', v_row.user_id,
      'email', v_row.email,
      'display_name', v_row.display_name,
      'role', v_row.role,
      'is_active', v_row.is_active
    );
  end if;

  -- Fallback when provisioned strictly via auth.jwt() -> app_metadata ->> 'role' = 'admin'.
  return jsonb_build_object(
    'user_id', v_uid,
    'email', coalesce(v_jwt ->> 'email', ''),
    'display_name', coalesce(nullif(v_jwt ->> 'email', ''), 'ChapterNo Admin'),
    'role', 'super_admin',
    'is_active', true
  );
end;
$$;

revoke all on function public.get_admin_profile() from public;
grant execute on function public.get_admin_profile() to authenticated;
