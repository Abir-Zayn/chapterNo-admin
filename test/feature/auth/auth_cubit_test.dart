// Bloc unit tests for AuthCubit state transitions and error handling.
// Covers session restore, admin sign-in, student block, and sign-out.
import 'package:bloc_test/bloc_test.dart';
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/feature/auth/domain/admin_user.dart';
import 'package:chapterno_admin/feature/auth/domain/auth_repository.dart';
import 'package:chapterno_admin/feature/auth/screens/bloc/auth_cubit.dart';
import 'package:chapterno_admin/feature/auth/screens/bloc/auth_state.dart';
import 'package:chapterno_admin/feature/auth/types/admin_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;

  const sampleAdmin = AdminUser(
    userId: 'u-1',
    email: 'admin@chapterno.com',
    displayName: 'Ayesha Rahman',
    role: AdminRole.superAdmin,
    isActive: true,
  );

  setUp(() {
    repository = _MockAuthRepository();
  });

  blocTest<AuthCubit, AuthState>(
    'restoreSession emits checking -> unauthenticated when no session exists',
    build: () {
      when(() => repository.restoreSession()).thenAnswer((_) async => null);
      return AuthCubit(repository);
    },
    act: (cubit) => cubit.restoreSession(),
    expect: () => [
      const AuthState(status: AuthStatus.checking),
      const AuthState(status: AuthStatus.unauthenticated),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'restoreSession emits checking -> unauthorized when student session found',
    build: () {
      when(() => repository.restoreSession())
          .thenThrow(const UnauthorizedAdminFailure());
      return AuthCubit(repository);
    },
    act: (cubit) => cubit.restoreSession(),
    expect: () => [
      const AuthState(status: AuthStatus.checking),
      const AuthState(
        status: AuthStatus.unauthorized,
        errorMessage: 'Access denied. This dashboard is restricted to verified ChapterNo admins.',
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signIn emits authenticated with adminUser on valid credentials',
    build: () {
      when(
        () => repository.signInWithEmail(
          email: 'admin@chapterno.com',
          password: 'secret',
        ),
      ).thenAnswer((_) async => sampleAdmin);
      return AuthCubit(repository);
    },
    act: (cubit) =>
        cubit.signIn(email: 'admin@chapterno.com', password: 'secret'),
    expect: () => [
      const AuthState(isSubmitting: true),
      const AuthState(
        status: AuthStatus.authenticated,
        adminUser: sampleAdmin,
        isSubmitting: false,
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signOut resets state to unauthenticated',
    build: () {
      when(() => repository.signOut()).thenAnswer((_) async {});
      return AuthCubit(repository);
    },
    seed: () => const AuthState(
      status: AuthStatus.authenticated,
      adminUser: sampleAdmin,
    ),
    act: (cubit) => cubit.signOut(),
    expect: () => [
      const AuthState(
        status: AuthStatus.authenticated,
        adminUser: sampleAdmin,
        isSubmitting: true,
      ),
      const AuthState(status: AuthStatus.unauthenticated, isSubmitting: false),
    ],
  );
}
