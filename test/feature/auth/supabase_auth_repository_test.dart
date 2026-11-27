// Unit tests for SupabaseAuthRepository admin role guard.
// Ensures student or inactive sessions are immediately cleared and blocked.
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/core/supabase/supabase_service.dart';
import 'package:chapterno_admin/feature/auth/data/supabase_auth_repository.dart';
import 'package:chapterno_admin/feature/auth/types/admin_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseService extends Mock implements SupabaseService {}

class _MockSession extends Mock implements Session {}

void main() {
  late _MockSupabaseService supabase;
  late SupabaseAuthRepository repository;

  setUp(() {
    supabase = _MockSupabaseService();
    repository = SupabaseAuthRepository(supabase);
    when(() => supabase.signOut()).thenAnswer((_) async {});
  });

  group('restoreSession', () {
    test('returns null when no session exists', () async {
      when(() => supabase.currentSession).thenReturn(null);

      final result = await repository.restoreSession();

      expect(result, isNull);
      verifyNever(() => supabase.rpc(any()));
    });

    test('returns AdminUser when get_admin_profile succeeds', () async {
      when(() => supabase.currentSession).thenReturn(_MockSession());
      when(() => supabase.rpc('get_admin_profile')).thenAnswer(
        (_) async => {
          'user_id': 'admin-1',
          'email': 'editor@chapterno.com',
          'display_name': 'Editorial Lead',
          'role': 'super_admin',
          'is_active': true,
        },
      );

      final admin = await repository.restoreSession();

      expect(admin, isNotNull);
      expect(admin!.role, AdminRole.superAdmin);
      expect(admin.email, 'editor@chapterno.com');
      verifyNever(() => supabase.signOut());
    });

    test(
      'clears session and throws UnauthorizedAdminFailure for non-admin',
      () async {
        when(() => supabase.currentSession).thenReturn(_MockSession());
        when(() => supabase.rpc('get_admin_profile')).thenThrow(
          const PostgrestException(
            message: 'Admin privileges required.',
            code: '42501',
          ),
        );

        await expectLater(
          repository.restoreSession(),
          throwsA(isA<UnauthorizedAdminFailure>()),
        );
        verify(() => supabase.signOut()).called(1);
      },
    );

    test('clears session when admin account is inactive', () async {
      when(() => supabase.currentSession).thenReturn(_MockSession());
      when(() => supabase.rpc('get_admin_profile')).thenAnswer(
        (_) async => {
          'user_id': 'admin-2',
          'email': 'disabled@chapterno.com',
          'display_name': 'Disabled Editor',
          'role': 'editor',
          'is_active': false,
        },
      );

      await expectLater(
        repository.restoreSession(),
        throwsA(isA<UnauthorizedAdminFailure>()),
      );
      verify(() => supabase.signOut()).called(1);
    });
  });

  group('signInWithEmail', () {
    test('signs out non-admin student immediately after login', () async {
      final session = Session(
        accessToken: 'student-token',
        tokenType: 'bearer',
        user: const User(
          id: 'student-1',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-01-01T00:00:00Z',
        ),
      );
      when(
        () => supabase.signInWithPassword(
          email: 'student@chapterno.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => AuthResponse(session: session));
      when(() => supabase.rpc('get_admin_profile')).thenThrow(
        const PostgrestException(
          message: 'Admin privileges required.',
          code: '42501',
        ),
      );

      await expectLater(
        repository.signInWithEmail(
          email: 'student@chapterno.com',
          password: 'password123',
        ),
        throwsA(isA<UnauthorizedAdminFailure>()),
      );
      verify(() => supabase.signOut()).called(1);
    });
  });
}
