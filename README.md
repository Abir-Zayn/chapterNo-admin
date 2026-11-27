# chapterNo-admin

Internal Flutter Web administration and content-authoring dashboard for **ChapterNo**, backed by Supabase.

## Setup & Run

1. Copy `.env.example` to `.env` and fill in `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` (never use `service_role` or `sb_secret_` keys):
   ```powershell
   Copy-Item .env.example .env
   ```
2. Apply Supabase migrations in `supabase/migrations/` and provision your admin user in `public.admin_users`.
3. Run the web app in Chrome:
   ```powershell
   flutter run -d chrome --dart-define-from-file=.env
   ```
4. Verify static analysis and tests:
   ```powershell
   flutter analyze; flutter test
   ```
