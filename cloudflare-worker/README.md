# chapterno-dashboard Cloudflare Worker

Serves the Flutter web build of the ChapterNo admin dashboard from a
Workers KV namespace and proxies the Supabase API so credentials never
ship to the client. Deployed at
https://chapterno-dashboard.kiroclaude902.workers.dev.

## How it works

- `flutter build web` output is uploaded to the `chapterno-admin-assets`
  KV namespace (`id` in `wrangler.jsonc`); the Worker serves those keys
  as static files. Files larger than ~3 MB are stored as `.c0`, `.c1`, ...
  chunks and reassembled on request (the upload API caps request size).
- `/health` returns `{ok:true}`; `/auth/v1/*`, `/rest/v1/*` and `/graphql/v1/*`
  are proxied to Supabase; every other path is served from KV, with unknown
  paths falling back to `index.html` (SPA mode).
- The Worker injects the real Supabase URL and publishable key from
  server-side secret bindings. The client ships only a placeholder key:
  any non-JWT `Authorization` bearer is replaced with the real key before
  the request leaves Cloudflare; session JWTs pass through untouched.
- Same origin in production, so no CORS applies; the CORS headers are kept
  so local `flutter run -d chrome` against the deployed Worker still works.

> Why KV and not Workers static assets? The assets upload pipeline
> (`assets/upload-session` + `workers/assets/upload`) returned
> `401 Unauthorized` for every upload attempt on this account — a
> Cloudflare-side outage others have hit since Oct 2026. KV upload and
> Worker script deploy both work, so assets ride on KV.

## Secrets and bindings (never commit)

| Name                   | Type          | Value                       |
| ---------------------- | ------------- | --------------------------- |
| `SUPABASE_URL`         | secret_text   | `https://<ref>.supabase.co` |
| `SUPABASE_PUBLISHABLE_KEY` | secret_text | `sb_publishable_...`      |
| `ASSETS_KV`            | kv_namespace  | `chapterno-admin-assets`    |

## Deploy

```sh
flutter build web --release --dart-define-from-file=.env
# upload build/web to the KV namespace (path = key, value = file bytes;
# split into ~2.8 MB .c<N> chunks above that), then:
npx wrangler deploy   # run inside cloudflare-worker/
```

Secrets set with `wrangler secret put` stay bound across deploys.
