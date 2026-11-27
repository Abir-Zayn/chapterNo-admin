// Compile-time API configuration loaded via --dart-define-from-file=.env.
// The URL points at the Cloudflare Worker proxy, not Supabase directly, so
// the real Supabase URL and key never ship in the client bundle.
// Enforces non-empty HTTP(S) URL and rejects secret or service_role keys.
import 'imports/env_config_imports.dart';

final class EnvConfig {
  const EnvConfig._({
    required this.supabaseProxyUrl,
    required this.supabasePublishableKey,
  });

  final String supabaseProxyUrl;
  final String supabasePublishableKey;

  static const String _envProxyUrl = String.fromEnvironment(
    'SUPABASE_PROXY_URL',
  );
  static const String _envPublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Validates environment values injected via `--dart-define-from-file=.env`.
  factory EnvConfig.fromEnvironment() {
    return EnvConfig.fromValues(
      supabaseProxyUrl: _envProxyUrl,
      supabasePublishableKey: _envPublishableKey,
    );
  }

  /// Validates explicit [supabaseProxyUrl] and [supabasePublishableKey] strings.
  factory EnvConfig.fromValues({
    required String supabaseProxyUrl,
    required String supabasePublishableKey,
  }) {
    final trimmedUrl = supabaseProxyUrl.trim();
    final trimmedKey = supabasePublishableKey.trim();

    if (trimmedUrl.isEmpty) {
      throw const EnvConfigFailure(
        'Missing SUPABASE_PROXY_URL. Pass --dart-define-from-file=.env when running.',
        code: 'missing_supabase_url',
      );
    }

    final parsed = Uri.tryParse(trimmedUrl);
    if (parsed == null ||
        !parsed.hasScheme ||
        (parsed.scheme != 'https' && parsed.scheme != 'http') ||
        parsed.host.isEmpty) {
      throw const EnvConfigFailure(
        'Invalid SUPABASE_PROXY_URL. Expected a valid http/https proxy URL.',
        code: 'invalid_supabase_url',
      );
    }

    if (trimmedKey.isEmpty) {
      throw const EnvConfigFailure(
        'Missing SUPABASE_PUBLISHABLE_KEY. Pass --dart-define-from-file=.env.',
        code: 'missing_publishable_key',
      );
    }

    final lowerKey = trimmedKey.toLowerCase();
    if (lowerKey.startsWith('sb_secret_') ||
        lowerKey.contains('service_role')) {
      throw const EnvConfigFailure(
        'Security violation: service_role or sb_secret keys are forbidden in Flutter client builds.',
        code: 'forbidden_secret_key',
      );
    }

    return EnvConfig._(
      supabaseProxyUrl: trimmedUrl,
      supabasePublishableKey: trimmedKey,
    );
  }

  /// Host shown on the settings screen; the worker proxy host, not Supabase.
  String get apiHost => Uri.parse(supabaseProxyUrl).host;
}
