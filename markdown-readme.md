Build **ChapterNo Admin Dashboard** — an internal Flutter (Web only) administration and content-authoring application for **ChapterNo** (a Bangladesh-first academic eduational learning platform backed by Supabase).

### 1. Execution Mode (Token-Efficient & Step-by-Step)
- Do NOT try to generate the entire application in one turn.
- First, create a concise, milestone-based **Implementation Plan** (`M1` -> `M5`) with database schema/RPC contracts and folder structure, then start **only Milestone 1** (or ask which milestone to execute first).

### 2. Confirmed Tech Stack & Architecture Rules
- **Framework:** Flutter stable / Dart 3 targeting **Web ** (responsive split-pane desktop layout, keyboard-friendly forms, `SelectionArea` support).
- **Backend:** Same Supabase project used by the student app (`supabase_flutter` with `--dart-define-from-file=.env` containing ONLY `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`).
- **State Management & Routing:** `flutter_bloc` (prefer `Cubit` for straightforward state, `Bloc` when event concurrency is needed) + `go_router` + constructor dependency injection (`RepositoryProvider` / `BlocProvider`). Do **NOT** use Riverpod or `get_it`.
- **Clean Architecture & File Discipline:**
  - Feature-based Clean Architecture (`lib/config/`, `lib/core/`, `lib/shared/`, `lib/feature/<name>/{domain,data,screens}`).
  - Domain layer must stay pure Dart (no Flutter, Bloc, or Supabase imports).
  - Every manually maintained Dart file must start with a 2–3 line purpose comment, keep imports in a paired `*_imports.dart` barrel, and stay under **300 physical lines** (150–220 preferred).

### 3. Non-Negotiable Supabase Security Rules
- **NEVER** put `service_role` / `sb_secret_...` keys inside `.env` or Flutter client code.
- **Admin Authorization:** Enforce admin access strictly in Postgres RLS (`TO authenticated`) and RPCs using a server-protected `public.admin_users` table or `auth.jwt() -> 'app_metadata' ->> 'role' = 'admin'` (**never** trust editable `user_metadata` or client-only flags).
- If a signed-in student (non-admin) logs into the Admin Dashboard, immediately block access, clear session, and show an unauthorized notice.
- All `auth.uid()` checks in RLS must use cached scalar subqueries `(select auth.uid())`, all foreign keys must be indexed, and `UPDATE` policies must define both `USING` and `WITH CHECK`.

### 4. Core MVP Features to Plan & Build (In Order)

1. **M1 — Bootstrap, Admin Auth & Role Guard:**
   - Crash-safe `main()` + `bootstrap.dart`, `.env` validation, Admin Login screen, session restore, and desktop sidebar shell (`Curriculum`, `MCQ Studio`, `Bulk Import`, `Question Bank`, `Settings`).
2. **M2 — Curriculum Catalogue Manager (`education_boards`, `subjects`, `chapters`, `topics`):**
   - Manage Bangladesh Education Boards and NCTB SSC hierarchy (`Subject -> Chapter -> Topic`) with bilingual fields (`title_bn`, `title_en`), `academic_group` (`common`, `science`, `business_studies`, `humanities`), `sort_order`, `provenance_source` (`nctb_syllabus` | `curated_editorial`), `rights_status` (`internal_draft` | `cleared`), and `is_active`.
3. **M3 — Bangla MCQ Studio + Live 360dp Mobile Preview:**
   - Create/edit SSC MCQs in **UTF-8 Bangla Unicode** across all 3 NCTB formats:
     1. *Simple MCQ* (`stem_bn` + 4 options).
     2. *Multiple-Completion (`i, ii, iii`)* (`statements` JSON array + stem).
     3. *Stimulus / Passage-based* (`stimulus_bn` + optional diagram upload to Supabase Storage).
   - Store option codes internally as `'A' | 'B' | 'C' | 'D'` while displaying Bangla badges (`ক, খ, গ, ঘ`).
   - **Split-Table Security:** Write questions to `public.mcq_questions` and secret answers/explanations (`correct_option`, `explanation_bn`, `is_verified`) to `public.mcq_answer_keys` atomically via a transactional Postgres RPC so students cannot read answer keys before submitting a quiz.
   - Include a side-by-side **360dp Student Phone Preview Card** using `Hind Siliguri` (Bangla) and `Inter` (English) so editors can spot clipped Bangla vowel marks or formula issues before publishing (`internal_draft` -> `cleared`).
4. **M4 — Bulk CSV / JSON Importer (Google Sheets Workflow):**
   - Upload UTF-8 `.csv` / `.json` exported from Google Sheets.
   - Run client + server validation before commit: detect and reject legacy **Bijoy ANSI** text, validate `subject_code`/`chapter_number`/`board_code`, enforce `correct_option in ('A','B','C','D')`, preview row-level errors in a table, and batch-upsert idempotently via `external_code`.
5. **M5 — Question Bank Browser, Filters & Audit Readiness:**
   - Paginated filter/search by Subject, Chapter, Topic, Board, Exam Year, Source (`board` vs `curated`), Difficulty, and Status (`internal_draft` vs `cleared`), plus version bump on edits (`version = version + 1`) so historical student attempts stay accurate.

### 5. Visual & UI Rules
- Light-first, calm academic workspace matching ChapterNo tokens: canvas `#FCFCFB`, solid white surfaces `#FFFFFF`, `1dp` borders `#E4E4E7`, primary coral `#FF5A5F`, text `#18181B` / `#71717A`, Phosphor icons.
- **Strictly NO glassmorphism, backdrop blur, or frosted translucent panels.**
- Provide clear loading, empty, validation-error, and retry states, and run `dart format .`, `flutter analyze`, and `flutter test` at the end of each milestone.

Start now by inspecting the workspace, writing the concise **Implementation Plan + SQL/RPC Schema for M1–M5**, and wait for my confirmation before writing M1 code.