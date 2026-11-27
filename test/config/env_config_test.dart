// Unit tests for EnvConfig validation and secret-key rejection.
// Verifies runtime guardrails for --dart-define-from-file=.env values.
import 'package:chapterno_admin/config/env/env_config.dart';
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvConfig.fromValues', () {
    test('accepts valid Supabase URL and publishable key', () {
      final config = EnvConfig.fromValues(
        supabaseUrl: 'https://demo-project.supabase.co',
        supabasePublishableKey: 'sb_publishable_abc123',
      );

      expect(config.supabaseUrl, 'https://demo-project.supabase.co');
      expect(config.supabasePublishableKey, 'sb_publishable_abc123');
      expect(config.projectHost, 'demo-project.supabase.co');
    });

    test('throws EnvConfigFailure when SUPABASE_URL is empty', () {
      expect(
        () => EnvConfig.fromValues(
          supabaseUrl: '   ',
          supabasePublishableKey: 'sb_publishable_abc123',
        ),
        throwsA(
          isA<EnvConfigFailure>().having(
            (e) => e.code,
            'code',
            'missing_supabase_url',
          ),
        ),
      );
    });

    test('throws EnvConfigFailure when SUPABASE_URL is invalid', () {
      expect(
        () => EnvConfig.fromValues(
          supabaseUrl: 'not-a-url',
          supabasePublishableKey: 'sb_publishable_abc123',
        ),
        throwsA(
          isA<EnvConfigFailure>().having(
            (e) => e.code,
            'code',
            'invalid_supabase_url',
          ),
        ),
      );
    });

    test('rejects sb_secret_ keys in client builds', () {
      expect(
        () => EnvConfig.fromValues(
          supabaseUrl: 'https://demo-project.supabase.co',
          supabasePublishableKey: 'sb_secret_dangerous_key',
        ),
        throwsA(
          isA<EnvConfigFailure>().having(
            (e) => e.code,
            'code',
            'forbidden_secret_key',
          ),
        ),
      );
    });

    test('rejects service_role keys in client builds', () {
      expect(
        () => EnvConfig.fromValues(
          supabaseUrl: 'https://demo-project.supabase.co',
          supabasePublishableKey: 'eyJ_service_role_token',
        ),
        throwsA(
          isA<EnvConfigFailure>().having(
            (e) => e.code,
            'code',
            'forbidden_secret_key',
          ),
        ),
      );
    });
  });
}
