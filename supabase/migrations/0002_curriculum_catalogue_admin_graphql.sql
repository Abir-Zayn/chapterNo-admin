-- Milestone 2: Curriculum Catalogue schema, audit triggers, role-based RLS,
-- and atomic reorder RPC exposed via Supabase pg_graphql.
-- Designed to be idempotent and safe when reconciling existing Step 1 tables.

-- 1. Role-check predicate alongside public.is_admin()
create or replace function public.has_admin_role(allowed_roles text[])
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.user_id = (select auth.uid())
      and au.is_active = true
      and au.role = any(allowed_roles)
  );
$$;

revoke all on function public.has_admin_role(text[]) from public;
grant execute on function public.has_admin_role(text[]) to authenticated;

-- 2. Server-enforced actor audit trigger (prevents GraphQL payload spoofing)
create or replace function public.audit_actor()
returns trigger
language plpgsql
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if tg_op = 'INSERT' then
    new.created_by := coalesce(v_uid, new.created_by);
    new.updated_by := coalesce(v_uid, new.updated_by);
  elsif tg_op = 'UPDATE' then
    new.created_by := old.created_by;
    new.updated_by := coalesce(v_uid, old.updated_by);
  end if;
  return new;
end;
$$;

-- 3. Canonical Curriculum Tables

-- 3.1 education_levels
create table if not exists public.education_levels (
  id uuid primary key default gen_random_uuid(),
  code text not null,
  name_bn text not null,
  name_en text not null,
  display_order integer not null default 0,
  is_active boolean not null default true,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint education_levels_code_key unique (code)
);

alter table public.education_levels
  add column if not exists code text,
  add column if not exists name_bn text,
  add column if not exists name_en text,
  add column if not exists display_order integer not null default 0,
  add column if not exists is_active boolean not null default true,
  add column if not exists archived_at timestamptz,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

-- 3.2 boards
create table if not exists public.boards (
  id uuid primary key default gen_random_uuid(),
  education_level_id uuid not null references public.education_levels(id) on delete restrict,
  code text not null,
  name_bn text not null,
  name_en text not null,
  display_order integer not null default 0,
  is_active boolean not null default true,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint boards_education_level_code_key unique (education_level_id, code)
);

alter table public.boards
  add column if not exists education_level_id uuid references public.education_levels(id) on delete restrict,
  add column if not exists code text,
  add column if not exists name_bn text,
  add column if not exists name_en text,
  add column if not exists display_order integer not null default 0,
  add column if not exists is_active boolean not null default true,
  add column if not exists archived_at timestamptz,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_boards_education_level_id
  on public.boards(education_level_id);

-- 3.3 subjects
create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  education_level_id uuid not null references public.education_levels(id) on delete restrict,
  code text not null,
  nctb_code text,
  academic_group text not null default 'common'
    check (academic_group in ('common', 'science', 'business_studies', 'humanities')),
  name_bn text not null,
  name_en text not null,
  short_name_bn text,
  display_order integer not null default 0,
  is_active boolean not null default true,
  archived_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint subjects_education_level_code_key unique (education_level_id, code)
);

alter table public.subjects
  add column if not exists education_level_id uuid references public.education_levels(id) on delete restrict,
  add column if not exists code text,
  add column if not exists nctb_code text,
  add column if not exists academic_group text not null default 'common',
  add column if not exists name_bn text,
  add column if not exists name_en text,
  add column if not exists short_name_bn text,
  add column if not exists display_order integer not null default 0,
  add column if not exists is_active boolean not null default true,
  add column if not exists archived_at timestamptz,
  add column if not exists created_by uuid references auth.users(id) on delete set null,
  add column if not exists updated_by uuid references auth.users(id) on delete set null,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_subjects_education_level_id
  on public.subjects(education_level_id);

-- 3.4 chapters
create table if not exists public.chapters (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid not null references public.subjects(id) on delete restrict,
  chapter_number integer not null check (chapter_number > 0),
  code text not null,
  name_bn text not null,
  name_en text not null,
  description_bn text,
  display_order integer not null default 0,
  is_active boolean not null default true,
  archived_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint chapters_subject_code_key unique (subject_id, code),
  constraint chapters_subject_number_key unique (subject_id, chapter_number)
);

alter table public.chapters
  add column if not exists subject_id uuid references public.subjects(id) on delete restrict,
  add column if not exists chapter_number integer,
  add column if not exists code text,
  add column if not exists name_bn text,
  add column if not exists name_en text,
  add column if not exists description_bn text,
  add column if not exists display_order integer not null default 0,
  add column if not exists is_active boolean not null default true,
  add column if not exists archived_at timestamptz,
  add column if not exists created_by uuid references auth.users(id) on delete set null,
  add column if not exists updated_by uuid references auth.users(id) on delete set null,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_chapters_subject_id
  on public.chapters(subject_id);

-- 3.5 topics
create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.chapters(id) on delete restrict,
  code text not null,
  name_bn text not null,
  name_en text not null,
  summary_bn text,
  display_order integer not null default 0,
  is_active boolean not null default true,
  archived_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint topics_chapter_code_key unique (chapter_id, code)
);

alter table public.topics
  add column if not exists chapter_id uuid references public.chapters(id) on delete restrict,
  add column if not exists code text,
  add column if not exists name_bn text,
  add column if not exists name_en text,
  add column if not exists summary_bn text,
  add column if not exists display_order integer not null default 0,
  add column if not exists is_active boolean not null default true,
  add column if not exists archived_at timestamptz,
  add column if not exists created_by uuid references auth.users(id) on delete set null,
  add column if not exists updated_by uuid references auth.users(id) on delete set null,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_topics_chapter_id
  on public.topics(chapter_id);

-- 4. Updated-at & Audit Triggers
drop trigger if exists trg_education_levels_updated_at on public.education_levels;
create trigger trg_education_levels_updated_at
  before update on public.education_levels
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_boards_updated_at on public.boards;
create trigger trg_boards_updated_at
  before update on public.boards
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_subjects_updated_at on public.subjects;
create trigger trg_subjects_updated_at
  before update on public.subjects
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_subjects_audit_actor on public.subjects;
create trigger trg_subjects_audit_actor
  before insert or update on public.subjects
  for each row execute function public.audit_actor();

drop trigger if exists trg_chapters_updated_at on public.chapters;
create trigger trg_chapters_updated_at
  before update on public.chapters
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_chapters_audit_actor on public.chapters;
create trigger trg_chapters_audit_actor
  before insert or update on public.chapters
  for each row execute function public.audit_actor();

drop trigger if exists trg_topics_updated_at on public.topics;
create trigger trg_topics_updated_at
  before update on public.topics
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_topics_audit_actor on public.topics;
create trigger trg_topics_audit_actor
  before insert or update on public.topics
  for each row execute function public.audit_actor();

-- 4b. Reconcile legacy Step 1 columns (title_bn, title_en, sort_order, etc.)
-- Keeps Step 1 student reads working while M2 GraphQL writes name_bn/name_en/display_order.
create or replace function public.sync_legacy_curriculum_columns()
returns trigger
language plpgsql
as $$
declare
  v_row jsonb := to_jsonb(new);
  v_patch jsonb := '{}'::jsonb;
begin
  if v_row ? 'title_bn' and coalesce(nullif(new.name_bn, ''), '') <> '' then
    v_patch := v_patch || jsonb_build_object('title_bn', new.name_bn);
  end if;
  if v_row ? 'title_en' and coalesce(nullif(new.name_en, ''), '') <> '' then
    v_patch := v_patch || jsonb_build_object('title_en', new.name_en);
  end if;
  if v_row ? 'title' and coalesce(nullif(new.name_en, ''), '') <> '' then
    v_patch := v_patch || jsonb_build_object('title', new.name_en);
  end if;
  if v_row ? 'sort_order' and new.display_order is not null then
    v_patch := v_patch || jsonb_build_object('sort_order', new.display_order);
  end if;
  if v_patch <> '{}'::jsonb then
    new := jsonb_populate_record(new, v_patch);
  end if;
  return new;
end;
$$;

do $$
declare
  v_tbl text;
  v_col text;
begin
  foreach v_tbl in array array['education_levels', 'boards', 'subjects', 'chapters', 'topics'] loop
    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = v_tbl and column_name = 'title_bn'
    ) then
      execute format('update public.%I set name_bn = coalesce(name_bn, title_bn) where name_bn is null', v_tbl);
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = v_tbl and column_name = 'title_en'
    ) then
      execute format('update public.%I set name_en = coalesce(name_en, title_en) where name_en is null', v_tbl);
    end if;

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'public' and table_name = v_tbl and column_name = 'sort_order'
    ) then
      execute format('update public.%I set display_order = coalesce(display_order, sort_order, 0) where display_order = 0 and sort_order is not null', v_tbl);
    end if;

    for v_col in
      select c.column_name
      from information_schema.columns c
      where c.table_schema = 'public'
        and c.table_name = v_tbl
        and c.is_nullable = 'NO'
        and c.column_default is null
        and c.column_name not in (
          'id', 'education_level_id', 'subject_id', 'chapter_id',
          'chapter_number', 'code', 'name_bn', 'name_en',
          'display_order', 'is_active', 'created_at', 'updated_at'
        )
    loop
      execute format('alter table public.%I alter column %I drop not null', v_tbl, v_col);
    end loop;

    execute format('drop trigger if exists trg_%I_sync_legacy on public.%I', v_tbl, v_tbl);
    execute format(
      'create trigger trg_%I_sync_legacy before insert or update on public.%I for each row execute function public.sync_legacy_curriculum_columns()',
      v_tbl, v_tbl
    );
  end loop;
end;
$$;

-- 5. Row Level Security Policies
alter table public.education_levels enable row level security;
alter table public.boards enable row level security;
alter table public.subjects enable row level security;
alter table public.chapters enable row level security;
alter table public.topics enable row level security;

-- SELECT: Admins read all; authenticated students read active, non-archived rows only.
drop policy if exists education_levels_select_policy on public.education_levels;
create policy education_levels_select_policy
  on public.education_levels
  for select
  to authenticated
  using (
    public.is_admin()
    or (is_active = true and archived_at is null)
  );

drop policy if exists boards_select_policy on public.boards;
create policy boards_select_policy
  on public.boards
  for select
  to authenticated
  using (
    public.is_admin()
    or (is_active = true and archived_at is null)
  );

drop policy if exists subjects_select_policy on public.subjects;
create policy subjects_select_policy
  on public.subjects
  for select
  to authenticated
  using (
    public.is_admin()
    or (is_active = true and archived_at is null)
  );

drop policy if exists chapters_select_policy on public.chapters;
create policy chapters_select_policy
  on public.chapters
  for select
  to authenticated
  using (
    public.is_admin()
    or (is_active = true and archived_at is null)
  );

drop policy if exists topics_select_policy on public.topics;
create policy topics_select_policy
  on public.topics
  for select
  to authenticated
  using (
    public.is_admin()
    or (is_active = true and archived_at is null)
  );

-- INSERT / UPDATE: education_levels & boards (super_admin only)
drop policy if exists education_levels_insert_policy on public.education_levels;
create policy education_levels_insert_policy
  on public.education_levels
  for insert
  to authenticated
  with check (public.has_admin_role(array['super_admin']));

drop policy if exists education_levels_update_policy on public.education_levels;
create policy education_levels_update_policy
  on public.education_levels
  for update
  to authenticated
  using (public.has_admin_role(array['super_admin']))
  with check (public.has_admin_role(array['super_admin']));

drop policy if exists boards_insert_policy on public.boards;
create policy boards_insert_policy
  on public.boards
  for insert
  to authenticated
  with check (public.has_admin_role(array['super_admin']));

drop policy if exists boards_update_policy on public.boards;
create policy boards_update_policy
  on public.boards
  for update
  to authenticated
  using (public.has_admin_role(array['super_admin']))
  with check (public.has_admin_role(array['super_admin']));

-- INSERT / UPDATE: subjects, chapters, topics (super_admin, editor)
drop policy if exists subjects_insert_policy on public.subjects;
create policy subjects_insert_policy
  on public.subjects
  for insert
  to authenticated
  with check (public.has_admin_role(array['super_admin', 'editor']));

drop policy if exists subjects_update_policy on public.subjects;
create policy subjects_update_policy
  on public.subjects
  for update
  to authenticated
  using (public.has_admin_role(array['super_admin', 'editor']))
  with check (public.has_admin_role(array['super_admin', 'editor']));

drop policy if exists chapters_insert_policy on public.chapters;
create policy chapters_insert_policy
  on public.chapters
  for insert
  to authenticated
  with check (public.has_admin_role(array['super_admin', 'editor']));

drop policy if exists chapters_update_policy on public.chapters;
create policy chapters_update_policy
  on public.chapters
  for update
  to authenticated
  using (public.has_admin_role(array['super_admin', 'editor']))
  with check (public.has_admin_role(array['super_admin', 'editor']));

drop policy if exists topics_insert_policy on public.topics;
create policy topics_insert_policy
  on public.topics
  for insert
  to authenticated
  with check (public.has_admin_role(array['super_admin', 'editor']));

drop policy if exists topics_update_policy on public.topics;
create policy topics_update_policy
  on public.topics
  for update
  to authenticated
  using (public.has_admin_role(array['super_admin', 'editor']))
  with check (public.has_admin_role(array['super_admin', 'editor']));

-- DELETE: super_admin only (ON DELETE RESTRICT FKs protect referenced nodes)
drop policy if exists education_levels_delete_policy on public.education_levels;
create policy education_levels_delete_policy
  on public.education_levels
  for delete
  to authenticated
  using (public.has_admin_role(array['super_admin']));

drop policy if exists boards_delete_policy on public.boards;
create policy boards_delete_policy
  on public.boards
  for delete
  to authenticated
  using (public.has_admin_role(array['super_admin']));

drop policy if exists subjects_delete_policy on public.subjects;
create policy subjects_delete_policy
  on public.subjects
  for delete
  to authenticated
  using (public.has_admin_role(array['super_admin']));

drop policy if exists chapters_delete_policy on public.chapters;
create policy chapters_delete_policy
  on public.chapters
  for delete
  to authenticated
  using (public.has_admin_role(array['super_admin']));

drop policy if exists topics_delete_policy on public.topics;
create policy topics_delete_policy
  on public.topics
  for delete
  to authenticated
  using (public.has_admin_role(array['super_admin']));

-- Table privileges required by pg_graphql to generate Query & Mutation fields
-- (row-level authorization is still enforced strictly by the RLS policies above).
grant select, insert, update, delete on table public.education_levels to authenticated;
grant select, insert, update, delete on table public.boards to authenticated;
grant select, insert, update, delete on table public.subjects to authenticated;
grant select, insert, update, delete on table public.chapters to authenticated;
grant select, insert, update, delete on table public.topics to authenticated;

-- 6. Atomic Reorder RPC (exposed as pg_graphql Mutation: reorderCurriculumNodes)
create or replace function public.reorder_curriculum_nodes(
  p_entity text,
  p_parent_id uuid,
  p_ordered_ids uuid[]
)
returns integer
language plpgsql
volatile
security invoker
set search_path = public, pg_temp
as $$
declare
  v_updated integer := 0;
begin
  if not public.has_admin_role(array['super_admin', 'editor']) then
    raise exception 'Forbidden: insufficient role to reorder curriculum'
      using errcode = '42501';
  end if;

  if p_entity = 'subject' then
    with ord as (
      select unnest(p_ordered_ids) as id, generate_subscripts(p_ordered_ids, 1) as pos
    )
    update public.subjects s
    set display_order = ord.pos
    from ord
    where s.id = ord.id
      and s.education_level_id = p_parent_id;
  elsif p_entity = 'chapter' then
    with ord as (
      select unnest(p_ordered_ids) as id, generate_subscripts(p_ordered_ids, 1) as pos
    )
    update public.chapters c
    set display_order = ord.pos
    from ord
    where c.id = ord.id
      and c.subject_id = p_parent_id;
  elsif p_entity = 'topic' then
    with ord as (
      select unnest(p_ordered_ids) as id, generate_subscripts(p_ordered_ids, 1) as pos
    )
    update public.topics t
    set display_order = ord.pos
    from ord
    where t.id = ord.id
      and t.chapter_id = p_parent_id;
  else
    raise exception 'Invalid entity: %', p_entity
      using errcode = '22023';
  end if;

  get diagnostics v_updated = row_count;
  return v_updated;
end;
$$;

revoke all on function public.reorder_curriculum_nodes(text, uuid, uuid[]) from public;
grant execute on function public.reorder_curriculum_nodes(text, uuid, uuid[]) to authenticated;

-- 7. Enable camelCase inflection in pg_graphql and refresh GraphQL schema cache
comment on schema public is e'@graphql({"inflect_names": true})';
