// Compile-time Supabase configuration loaded via --dart-define-from-file=.env.
// Enforces non-empty HTTPS URL and rejects secret or service_role keys.
import 'imports/env_config_imports.dart';

final class EnvConfig {
  const EnvConfig._({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
  });

  final String supabaseUrl;
  final String supabasePublishableKey;

  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envPublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Validates environment values injected via `--dart-define-from-file=.env`.
  factory EnvConfig.fromEnvironment() {
    return EnvConfig.fromValues(
      supabaseUrl: _envUrl,
      supabasePublishableKey: _envPublishableKey,
    );
  }

  /// Validates explicit [supabaseUrl] and [supabasePublishableKey] strings.
  factory EnvConfig.fromValues({
    required String supabaseUrl,
    required String supabasePublishableKey,
  }) {
    final trimmedUrl = supabaseUrl.trim();
    final trimmedKey = supabasePublishableKey.trim();

    if (trimmedUrl.isEmpty) {
      throw const EnvConfigFailure(
        'Missing SUPABASE_URL. Pass --dart-define-from-file=.env when running.',
        code: 'missing_supabase_url',
      );
    }

    final parsed = Uri.tryParse(trimmedUrl);
    if (parsed == null ||
        !parsed.hasScheme ||
        (parsed.scheme != 'https' && parsed.scheme != 'http') ||
        parsed.host.isEmpty) {
      throw const EnvConfigFailure(
        'Invalid SUPABASE_URL. Expected a valid http/https Supabase project URL.',
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
      supabaseUrl: trimmedUrl,
      supabasePublishableKey: trimmedKey,
    );
  }

  String get projectHost => Uri.parse(supabaseUrl).host;
}
