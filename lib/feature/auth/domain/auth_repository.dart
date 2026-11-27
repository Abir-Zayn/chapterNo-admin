// Pure-Dart repository contract for admin authentication and role verification.
// Implemented by data/SupabaseAuthRepository and mocked cleanly in unit tests.
import 'auth_repository_imports.dart';

abstract interface class AuthRepository {
  /// Restores an existing Supabase session and verifies admin status via RPC.
  /// Returns null when no session exists; clears session if user is non-admin.
  Future<AdminUser?> restoreSession();

  /// Signs in with email/password and verifies admin privileges via RPC.
  /// Immediately clears session and throws UnauthorizedAdminFailure for non-admins.
  Future<AdminUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs out the current user from Supabase Auth.
  Future<void> signOut();
}
