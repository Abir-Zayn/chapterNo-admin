-- Milestone 3: MCQ question bank with stimulus (উদ্দীপক) support, role-based RLS
-- with student answer-leak prevention, a student-safe published-question RPC, and
-- an atomic CSV/JSON bulk upsert RPC exposed via Supabase pg_graphql / PostgREST.
-- Designed to be idempotent and safe when reconciling existing tables.
-- Curriculum FKs (subject/chapter/topic) are bigint: production keeps the legacy
-- step1 tables whose ids are bigint (the local 0002 uuid-id variant was never
-- applied remotely). boards.id and question_stimuli.id are uuid.

-- 1. Stimulus table for stimulus-based MCQ groups
create table if not exists public.question_stimuli (
  id uuid primary key default gen_random_uuid(),
  chapter_id bigint not null references public.chapters(id) on delete restrict,
  topic_id bigint references public.topics(id) on delete set null,
  content_bn text not null,
  media_url text,
  archived_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.question_stimuli
  add column if not exists chapter_id bigint references public.chapters(id) on delete restrict,
  add column if not exists topic_id bigint references public.topics(id) on delete set null,
  add column if not exists content_bn text,
  add column if not exists media_url text,
  add column if not exists archived_at timestamptz,
  add column if not exists created_by uuid references auth.users(id) on delete set null,
  add column if not exists updated_by uuid references auth.users(id) on delete set null,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_question_stimuli_chapter_id
  on public.question_stimuli(chapter_id);

-- 2. MCQ question bank
create table if not exists public.mcq_questions (
  id uuid primary key default gen_random_uuid(),
  external_code text,
  subject_id bigint not null references public.subjects(id) on delete restrict,
  chapter_id bigint not null references public.chapters(id) on delete restrict,
  topic_id bigint references public.topics(id) on delete set null,
  stimulus_id uuid references public.question_stimuli(id) on delete set null,
  question_type text not null default 'simple'
    check (question_type in ('simple', 'multiple_completion', 'stimulus')),
  title text not null,
  statements jsonb,
  options jsonb not null
    check (jsonb_typeof(options) = 'array' and jsonb_array_length(options) >= 2),
  correct_option text not null
    check (options @> jsonb_build_array(jsonb_build_object('key', correct_option))),
  explanation text,
  difficulty text not null default 'l2'
    check (difficulty in ('l1', 'l2', 'l3')),
  source_type text not null default 'curated'
    check (source_type in ('board', 'curated', 'ai_generated')),
  board_id uuid references public.boards(id) on delete set null,
  exam_year integer
    check (exam_year is null or (exam_year >= 1990 and exam_year <= 2100)),
  rights_status text not null default 'internal'
    check (rights_status in ('internal', 'public_board', 'licensed', 'pending_review')),
  status text not null default 'draft'
    check (status in ('draft', 'in_review', 'published', 'archived')),
  is_verified boolean not null default false,
  version integer not null default 1 check (version > 0),
  archived_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  updated_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.mcq_questions
  add column if not exists external_code text,
  add column if not exists subject_id bigint references public.subjects(id) on delete restrict,
  add column if not exists chapter_id bigint references public.chapters(id) on delete restrict,
  add column if not exists topic_id bigint references public.topics(id) on delete set null,
  add column if not exists stimulus_id uuid references public.question_stimuli(id) on delete set null,
  add column if not exists question_type text not null default 'simple',
  add column if not exists title text,
  add column if not exists statements jsonb,
  add column if not exists options jsonb,
  add column if not exists correct_option text,
  add column if not exists explanation text,
  add column if not exists difficulty text not null default 'l2',
  add column if not exists source_type text not null default 'curated',
  add column if not exists board_id uuid references public.boards(id) on delete set null,
  add column if not exists exam_year integer,
  add column if not exists rights_status text not null default 'internal',
  add column if not exists status text not null default 'draft',
  add column if not exists is_verified boolean not null default false,
  add column if not exists version integer not null default 1,
  add column if not exists archived_at timestamptz,
  add column if not exists created_by uuid references auth.users(id) on delete set null,
  add column if not exists updated_by uuid references auth.users(id) on delete set null,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

-- 3. B-tree indexes for catalogue filtering + idempotent bulk upsert key
create index if not exists idx_mcq_questions_subject_chapter_status
  on public.mcq_questions(subject_id, chapter_id, status);
create index if not exists idx_mcq_questions_topic_id
  on public.mcq_questions(topic_id);
create index if not exists idx_mcq_questions_board_exam_year
  on public.mcq_questions(board_id, exam_year);
create index if not exists idx_mcq_questions_source_difficulty
  on public.mcq_questions(source_type, difficulty);
create index if not exists idx_mcq_questions_stimulus_id
  on public.mcq_questions(stimulus_id);
create unique index if not exists uq_mcq_questions_external_code
  on public.mcq_questions(external_code) where external_code is not null;

-- 4. Updated-at & Audit Triggers
drop trigger if exists trg_question_stimuli_updated_at on public.question_stimuli;
create trigger trg_question_stimuli_updated_at
  before update on public.question_stimuli
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_question_stimuli_audit_actor on public.question_stimuli;
create trigger trg_question_stimuli_audit_actor
  before insert or update on public.question_stimuli
  for each row execute function public.audit_actor();

drop trigger if exists trg_mcq_questions_updated_at on public.mcq_questions;
create trigger trg_mcq_questions_updated_at
  before update on public.mcq_questions
  for each row execute function public.touch_updated_at();

drop trigger if exists trg_mcq_questions_audit_actor on public.mcq_questions;
create trigger trg_mcq_questions_audit_actor
  before insert or update on public.mcq_questions
  for each row execute function public.audit_actor();

-- 5. Row Level Security Policies
alter table public.question_stimuli enable row level security;
alter table public.mcq_questions enable row level security;

-- SELECT: admins only. Students never read these tables directly; students
-- consume published questions through public.get_published_mcqs(), which strips
-- correct_option and explanation (answer-leak prevention before submission).
drop policy if exists question_stimuli_select_policy on public.question_stimuli;
create policy question_stimuli_select_policy
  on public.question_stimuli
  for select
  to authenticated
  using (public.has_admin_role(array['super_admin', 'editor', 'reviewer']));

drop policy if exists mcq_questions_select_policy on public.mcq_questions;
create policy mcq_questions_select_policy
  on public.mcq_questions
  for select
  to authenticated
  using (public.has_admin_role(array['super_admin', 'editor', 'reviewer']));

-- INSERT: super_admin + editor. Editors cannot create rows that are already
-- published or verified (same review gate as UPDATE below).
drop policy if exists question_stimuli_insert_policy on public.question_stimuli;
create policy question_stimuli_insert_policy
  on public.question_stimuli
  for insert
  to authenticated
  with check (public.has_admin_role(array['super_admin', 'editor']));

drop policy if exists mcq_questions_insert_policy on public.mcq_questions;
create policy mcq_questions_insert_policy
  on public.mcq_questions
  for insert
  to authenticated
  with check (
    public.has_admin_role(array['super_admin', 'editor'])
    and (
      public.has_admin_role(array['super_admin', 'reviewer'])
      or (status <> 'published' and is_verified = false)
    )
  );

-- UPDATE: editor may edit content but may never write status = 'published'
-- or is_verified = true; only reviewer or super_admin can (review gate).
-- Consequence: rows that are already published/verified are frozen for editors.
drop policy if exists question_stimuli_update_policy on public.question_stimuli;
create policy question_stimuli_update_policy
  on public.question_stimuli
  for update
  to authenticated
  using (public.has_admin_role(array['super_admin', 'editor', 'reviewer']))
  with check (public.has_admin_role(array['super_admin', 'editor', 'reviewer']));

drop policy if exists mcq_questions_update_policy on public.mcq_questions;
create policy mcq_questions_update_policy
  on public.mcq_questions
  for update
  to authenticated
  using (public.has_admin_role(array['super_admin', 'editor', 'reviewer']))
  with check (
    public.has_admin_role(array['super_admin', 'editor', 'reviewer'])
    and (
      public.has_admin_role(array['super_admin', 'reviewer'])
      or (status <> 'published' and is_verified = false)
    )
  );

-- DELETE: super_admin only (ON DELETE RESTRICT FKs protect referenced nodes)
drop policy if exists question_stimuli_delete_policy on public.question_stimuli;
create policy question_stimuli_delete_policy
  on public.question_stimuli
  for delete
  to authenticated
  using (public.has_admin_role(array['super_admin']));

drop policy if exists mcq_questions_delete_policy on public.mcq_questions;
create policy mcq_questions_delete_policy
  on public.mcq_questions
  for delete
  to authenticated
  using (public.has_admin_role(array['super_admin']));

-- 6. Table privileges required by pg_graphql to generate Query & Mutation fields
-- (row-level authorization is still enforced strictly by the RLS policies above).
grant select, insert, update, delete on table public.question_stimuli to authenticated;
grant select, insert, update, delete on table public.mcq_questions to authenticated;

-- 7. Student-safe published MCQ RPC (PostgREST: POST /rest/v1/rpc/get_published_mcqs)
-- SECURITY DEFINER bypasses RLS so students can read published questions while
-- correct_option and explanation are never returned.
create or replace function public.get_published_mcqs(
  p_chapter_id bigint,
  p_topic_id bigint default null,
  p_limit integer default 20
)
returns table (
  id uuid,
  question_type text,
  title text,
  statements jsonb,
  options jsonb,
  stimulus_id uuid,
  stimulus_content_bn text,
  stimulus_media_url text,
  difficulty text,
  source_type text,
  board_id uuid,
  exam_year integer,
  chapter_id bigint,
  topic_id bigint
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select q.id, q.question_type, q.title, q.statements, q.options,
         q.stimulus_id, s.content_bn, s.media_url,
         q.difficulty, q.source_type, q.board_id, q.exam_year,
         q.chapter_id, q.topic_id
  from public.mcq_questions q
  left join public.question_stimuli s on s.id = q.stimulus_id
  where q.status = 'published'
    and q.archived_at is null
    and q.chapter_id = p_chapter_id
    and (p_topic_id is null or q.topic_id = p_topic_id)
  order by q.created_at desc
  limit least(greatest(coalesce(p_limit, 20), 1), 100);
$$;

revoke all on function public.get_published_mcqs(bigint, bigint, integer) from public;
grant execute on function public.get_published_mcqs(bigint, bigint, integer) to authenticated;

-- 8. Bulk CSV/JSON upsert RPC (product-readme.md format; PostgREST or GraphQL
-- mutation upsertMcqBatch). SECURITY DEFINER so the import runs in one atomic
-- transaction; it never writes status/is_verified so it cannot bypass review.
-- Accepts per row: external_code, title, options (string array or {key, text}
-- object array), correct_ans/correct_option, level (l1-l3 difficulty, l4 =
-- board question at medium difficulty), explanation (also the CSV typo
-- "explaination"), chapter_id or subject_id + chapter_code, and optional
-- topic_id, stimulus_id, board_id, exam_year, question_type, statements,
-- difficulty, source_type, rights_status.
create or replace function public.upsert_mcq_batch(p_items jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_item jsonb;
  v_idx integer := 0;
  v_inserted integer := 0;
  v_updated integer := 0;
  v_is_insert boolean;
  v_external_code text;
  v_chapter_id bigint;
  v_subject_id bigint;
  v_topic_id bigint;
  v_stimulus_id uuid;
  v_board_id uuid;
  v_exam_year integer;
  v_title text;
  v_statements jsonb;
  v_options jsonb;
  v_option jsonb;
  v_norm_options jsonb;
  v_option_key text;
  v_option_keys text[];
  v_correct text;
  v_level text;
  v_difficulty text;
  v_source_type text;
  v_rights_status text;
  v_question_type text;
  v_explanation text;
begin
  if not public.has_admin_role(array['super_admin', 'editor']) then
    raise exception 'Forbidden: insufficient role to import MCQs'
      using errcode = '42501';
  end if;

  if p_items is null or jsonb_typeof(p_items) <> 'array' then
    raise exception 'p_items must be a JSON array of MCQ rows'
      using errcode = '22023';
  end if;

  for v_item in select jsonb_array_elements(p_items) loop
    v_idx := v_idx + 1;
    begin
      v_external_code := nullif(v_item->>'external_code', '');
      v_title := nullif(v_item->>'title', '');

      -- Resolve chapter: direct chapter_id, or subject_id + chapter_code.
      if nullif(v_item->>'chapter_id', '') is not null then
        v_chapter_id := (v_item->>'chapter_id')::bigint;
        select c.subject_id into v_subject_id
        from public.chapters c
        where c.id = v_chapter_id;
        if v_subject_id is null then
          raise exception 'chapter_id % not found', v_chapter_id
            using errcode = '23503';
        end if;
      else
        v_subject_id := nullif(v_item->>'subject_id', '')::bigint;
        if v_subject_id is null then
          raise exception 'chapter_id or subject_id + chapter_code is required'
            using errcode = '22023';
        end if;
        select c.id into v_chapter_id
        from public.chapters c
        where c.subject_id = v_subject_id
          and c.code = nullif(v_item->>'chapter_code', '');
        if v_chapter_id is null then
          raise exception 'no chapter matches subject_id % + chapter_code %',
            v_subject_id, coalesce(v_item->>'chapter_code', '')
            using errcode = '23503';
        end if;
      end if;

      v_topic_id := nullif(v_item->>'topic_id', '')::bigint;
      if v_topic_id is not null and not exists (
        select 1 from public.topics t
        where t.id = v_topic_id and t.chapter_id = v_chapter_id
      ) then
        raise exception 'topic_id % does not belong to chapter %', v_topic_id, v_chapter_id
          using errcode = '23503';
      end if;

      v_stimulus_id := nullif(v_item->>'stimulus_id', '')::uuid;
      v_board_id := nullif(v_item->>'board_id', '')::uuid;
      v_exam_year := nullif(v_item->>'exam_year', '')::integer;

      -- Options: array of strings (auto-keyed "1".."n") or {key, text} objects.
      v_options := v_item->'options';
      if v_options is null or jsonb_typeof(v_options) <> 'array'
        or jsonb_array_length(v_options) < 2 then
        raise exception 'options must be a JSON array with at least 2 entries'
          using errcode = '22023';
      end if;
      v_norm_options := '[]'::jsonb;
      v_option_keys := array[]::text[];
      for v_option in select jsonb_array_elements(v_options) loop
        if jsonb_typeof(v_option) = 'string' then
          v_option_key := (jsonb_array_length(v_norm_options) + 1)::text;
          v_norm_options := v_norm_options || jsonb_build_object('key', v_option_key, 'text', v_option #>> '{}');
        elsif jsonb_typeof(v_option) = 'object'
          and v_option ? 'key' and nullif(v_option->>'key', '') is not null
          and v_option ? 'text'
        then
          v_option_key := v_option->>'key';
          v_norm_options := v_norm_options || jsonb_build_object('key', v_option_key, 'text', v_option->>'text');
        else
          raise exception 'options entries must be strings or {key, text} objects'
            using errcode = '22023';
        end if;
        if v_option_key = any(v_option_keys) then
          raise exception 'duplicate option key %', v_option_key
            using errcode = '22023';
        end if;
        v_option_keys := v_option_keys || v_option_key;
      end loop;

      v_correct := nullif(coalesce(v_item->>'correct_ans', v_item->>'correct_option'), '');
      if v_correct is null then
        raise exception 'correct_ans (or correct_option) is required'
          using errcode = '22023';
      end if;
      if not (v_correct = any(v_option_keys)) then
        raise exception 'correct option % does not match any option key (%)',
          v_correct, array_to_string(v_option_keys, ', ')
          using errcode = '22023';
      end if;

      -- Level mapping: l1/l2/l3 -> difficulty; l4 = board question (medium).
      v_level := lower(nullif(v_item->>'level', ''));
      if v_level is not null and v_level not in ('l1', 'l2', 'l3', 'l4') then
        raise exception 'level must be one of l1, l2, l3, l4'
          using errcode = '22023';
      end if;
      v_difficulty := nullif(v_item->>'difficulty', '');
      if v_difficulty is null then
        v_difficulty := case when v_level in ('l1', 'l2', 'l3') then v_level else 'l2' end;
      end if;
      v_source_type := nullif(v_item->>'source_type', '');
      if v_source_type is null then
        v_source_type := case when v_level = 'l4' then 'board' else 'curated' end;
      end if;
      if v_difficulty not in ('l1', 'l2', 'l3') then
        raise exception 'difficulty must be one of l1, l2, l3'
          using errcode = '22023';
      end if;
      if v_source_type not in ('board', 'curated', 'ai_generated') then
        raise exception 'source_type must be one of board, curated, ai_generated'
          using errcode = '22023';
      end if;

      v_rights_status := nullif(v_item->>'rights_status', '');
      if v_rights_status is null then
        v_rights_status := case when v_source_type = 'board' then 'public_board' else 'internal' end;
      end if;
      if v_rights_status not in ('internal', 'public_board', 'licensed', 'pending_review') then
        raise exception 'rights_status must be one of internal, public_board, licensed, pending_review'
          using errcode = '22023';
      end if;

      v_question_type := coalesce(nullif(v_item->>'question_type', ''), 'simple');
      if v_question_type not in ('simple', 'multiple_completion', 'stimulus') then
        raise exception 'question_type must be one of simple, multiple_completion, stimulus'
          using errcode = '22023';
      end if;

      v_statements := nullif(v_item->'statements', 'null'::jsonb);
      if v_statements is not null and jsonb_typeof(v_statements) <> 'array' then
        raise exception 'statements must be a JSON array when provided'
          using errcode = '22023';
      end if;

      if v_title is null then
        raise exception 'title is required'
          using errcode = '22023';
      end if;

      -- Accept the product-readme.csv header typo "explaination" as an alias.
      v_explanation := coalesce(v_item->>'explanation', v_item->>'explaination');

      -- SECURITY DEFINER bypasses RLS: editors must not be able to overwrite
      -- published or verified rows through the bulk import path.
      if v_external_code is not null
        and not public.has_admin_role(array['super_admin', 'reviewer'])
        and exists (
          select 1 from public.mcq_questions q
          where q.external_code = v_external_code
            and (q.status = 'published' or q.is_verified = true)
        ) then
        raise exception 'Forbidden: cannot overwrite published or verified MCQ as editor'
          using errcode = '42501';
      end if;

      insert into public.mcq_questions (
        external_code, subject_id, chapter_id, topic_id, stimulus_id,
        question_type, title, statements, options, correct_option,
        explanation, difficulty, source_type, rights_status, board_id, exam_year
      ) values (
        v_external_code, v_subject_id, v_chapter_id, v_topic_id, v_stimulus_id,
        v_question_type, v_title, v_statements, v_norm_options, v_correct,
        v_explanation, v_difficulty, v_source_type, v_rights_status, v_board_id, v_exam_year
      )
      on conflict (external_code) where external_code is not null
      do update set
        subject_id = excluded.subject_id,
        chapter_id = excluded.chapter_id,
        topic_id = excluded.topic_id,
        stimulus_id = excluded.stimulus_id,
        question_type = excluded.question_type,
        title = excluded.title,
        statements = excluded.statements,
        options = excluded.options,
        correct_option = excluded.correct_option,
        explanation = excluded.explanation,
        difficulty = excluded.difficulty,
        source_type = excluded.source_type,
        rights_status = excluded.rights_status,
        board_id = excluded.board_id,
        exam_year = excluded.exam_year,
        version = public.mcq_questions.version + 1
      returning (xmax = 0) into v_is_insert;

      if v_is_insert then
        v_inserted := v_inserted + 1;
      else
        v_updated := v_updated + 1;
      end if;
    exception
      when others then
        raise exception 'MCQ row % (external_code: %) failed: %',
          v_idx, coalesce(v_external_code, '<null>'), sqlerrm
          using errcode = sqlstate;
    end;
  end loop;

  return jsonb_build_object(
    'inserted', v_inserted,
    'updated', v_updated,
    'total', v_idx
  );
end;
$$;

revoke all on function public.upsert_mcq_batch(jsonb) from public;
grant execute on function public.upsert_mcq_batch(jsonb) to authenticated;

-- 9. Enable camelCase inflection in pg_graphql and refresh GraphQL schema cache
comment on schema public is e'@graphql({"inflect_names": true})';
