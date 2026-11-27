// chapterno-dashboard Cloudflare Worker.
// Serves the Flutter web build from a Workers KV namespace (files are
// uploaded to KV after "flutter build web") and proxies the Supabase
// auth/PostgREST/GraphQL API with server-side credentials, so the client bundle never
// contains the real Supabase URL or publishable key.

const CORS_HEADERS = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
  'access-control-allow-headers':
    'apikey,authorization,content-type,x-client-info,x-supabase-api-version,content-profile,accept-profile',
  'access-control-max-age': '86400',
};

const PROXIED = [/^\/auth\/v1\//, /^\/rest\/v1\//, /^\/graphql\/v1\/?$/];

// Hop-by-hop or Cloudflare-injected headers that must not reach Supabase.
const DROP_HEADERS = new Set([
  'host',
  'connection',
  'content-length',
  'transfer-encoding',
  'cf-connecting-ip',
  'cf-ipcountry',
  'cf-ray',
  'cf-visitor',
  'cf-worker',
  'x-forwarded-for',
  'x-forwarded-proto',
  'x-real-ip',
]);

const MIME = {
  html: 'text/html; charset=utf-8',
  js: 'text/javascript; charset=utf-8',
  mjs: 'text/javascript; charset=utf-8',
  json: 'application/json; charset=utf-8',
  wasm: 'application/wasm',
  png: 'image/png',
  svg: 'image/svg+xml',
  ico: 'image/x-icon',
  ttf: 'font/ttf',
  otf: 'font/otf',
  woff: 'font/woff',
  woff2: 'font/woff2',
  map: 'application/json; charset=utf-8',
  frag: 'text/plain; charset=utf-8',
  sksl: 'text/plain; charset=utf-8',
  symbols: 'text/plain; charset=utf-8',
};

// Files whose content can change on every deploy: caches must revalidate.
const NO_CACHE = new Set([
  '/index.html',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/flutter_service_worker.js',
  '/manifest.json',
  '/version.json',
  '/.last_build_id',
  '/main.dart.js',
]);

function contentType(path) {
  const dot = path.lastIndexOf('.');
  if (dot < path.lastIndexOf('/')) return 'application/octet-stream';
  return MIME[path.slice(dot + 1)] || 'application/octet-stream';
}

// Large files are stored as .c0/.c1/... chunks (upload pipeline size cap);
// reassemble them transparently.
async function readAsset(env, key) {
  const KV_BINARY = { type: 'arrayBuffer' };
  const first = await env.ASSETS_KV.get(key + '.c0', KV_BINARY);
  if (first !== null) {
    const parts = [first];
    for (let i = 1; ; i++) {
      const part = await env.ASSETS_KV.get(key + '.c' + i, KV_BINARY);
      if (part === null) break;
      parts.push(part);
    }
    let total = 0;
    for (const part of parts) total += part.byteLength;
    const out = new Uint8Array(total);
    let offset = 0;
    for (const part of parts) {
      out.set(new Uint8Array(part), offset);
      offset += part.byteLength;
    }
    return out;
  }
  return env.ASSETS_KV.get(key, KV_BINARY);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      // Echo the client's requested headers so new supabase-js headers
      // (e.g. content-profile) never fail preflight again.
      const requested = request.headers.get('access-control-request-headers');
      const headers = {
        ...CORS_HEADERS,
        ...(requested && { 'access-control-allow-headers': requested }),
      };
      return new Response(null, { status: 204, headers });
    }
    if (url.pathname === '/health') {
      return Response.json({ ok: true });
    }
    if (PROXIED.some((re) => re.test(url.pathname))) {
      if (!env.SUPABASE_URL || !env.SUPABASE_PUBLISHABLE_KEY) {
        return Response.json({ error: 'proxy_unconfigured' }, { status: 503 });
      }

      const headers = new Headers();
      for (const [key, value] of request.headers) {
        if (DROP_HEADERS.has(key) || key === 'apikey' || key === 'authorization') {
          continue;
        }
        headers.set(key, value);
      }
      headers.set('apikey', env.SUPABASE_PUBLISHABLE_KEY);

      // Session access tokens are JWTs ("ey..."); anything else (the
      // placeholder key shipped in the client) is swapped for the real key.
      const token = request.headers.get('authorization')?.slice(7);
      headers.set(
        'authorization',
        token && token.startsWith('ey')
          ? 'Bearer ' + token
          : 'Bearer ' + env.SUPABASE_PUBLISHABLE_KEY,
      );

      const upstream =
        env.SUPABASE_URL.replace(/\/+$/, '') + url.pathname + url.search;
      let upstreamResponse;
      try {
        upstreamResponse = await fetch(upstream, {
          method: request.method,
          headers,
          // shortcut: admin JSON payloads are small, stream if uploads appear
          body:
            request.method === 'GET' || request.method === 'HEAD'
              ? undefined
              : await request.arrayBuffer(),
        });
      } catch {
        return Response.json({ error: 'upstream_unreachable' }, { status: 502 });
      }

      const response = new Response(upstreamResponse.body, upstreamResponse);
      response.headers.delete('content-length'); // body is re-chunked
      response.headers.delete('content-encoding'); // upstream decoded by fetch
      for (const [key, value] of Object.entries(CORS_HEADERS)) {
        response.headers.set(key, value);
      }
      return response;
    }

    // Static assets from KV.
    if (!env.ASSETS_KV) {
      return Response.json({ error: 'assets_unconfigured' }, { status: 503 });
    }
    const path = url.pathname === '/' ? '/index.html' : url.pathname;
    const body = await readAsset(env, path);
    if (body !== null) {
      return new Response(body, {
        status: 200,
        headers: {
          'content-type': contentType(path),
          'cache-control': NO_CACHE.has(path)
            ? 'no-cache'
            : 'public, max-age=86400',
        },
      });
    }
    // SPA fallback: client-side routes get the app shell.
    const shell = await readAsset(env, '/index.html');
    if (shell === null) {
      return Response.json({ error: 'not_found' }, { status: 404 });
    }
    return new Response(shell, {
      status: 200,
      headers: {
        'content-type': 'text/html; charset=utf-8',
        'cache-control': 'no-cache',
      },
    });
  },
};
