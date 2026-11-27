// Supabase-backed AuthRepository enforcing server-side admin verification.
// Signs out immediately if a student or deactivated account attempts access.
import 'imports/supabase_auth_repository_imports.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._supabase);

  final SupabaseService _supabase;

  @override
  Future<AdminUser?> restoreSession() async {
    if (_supabase.currentSession == null) {
      return null;
    }
    return _verifyAdminOrSignOut();
  }

  @override
  Future<AdminUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.session == null) {
        throw const AuthFailure(
          'Sign-in did not establish an active session. Please try again.',
        );
      }
      return await _verifyAdminOrSignOut();
    } on AppFailure {
      rethrow;
    } on AuthException catch (error) {
      throw AuthFailure(error.message, code: error.statusCode);
    } catch (error) {
      throw NetworkFailure('Failed to sign in: $error');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.signOut();
    } catch (error) {
      throw NetworkFailure('Failed to sign out: $error');
    }
  }

  Future<AdminUser> _verifyAdminOrSignOut() async {
    try {
      final result = await _supabase.rpc('get_admin_profile');
      if (result is! Map) {
        await _safeSignOut();
        throw const UnauthorizedAdminFailure();
      }
      final admin = AdminUser.fromMap(Map<String, dynamic>.from(result));
      if (!admin.isActive || admin.userId.isEmpty) {
        await _safeSignOut();
        throw const UnauthorizedAdminFailure(
          'Your admin account is inactive. Contact a super admin.',
        );
      }
      return admin;
    } on AppFailure {
      rethrow;
    } on PostgrestException catch (error) {
      await _safeSignOut();
      if (error.code == '42501' ||
          error.message.toLowerCase().contains('admin privileges')) {
        throw const UnauthorizedAdminFailure();
      }
      throw NetworkFailure('Admin verification failed: ${error.message}');
    } catch (error) {
      await _safeSignOut();
      throw NetworkFailure('Unable to verify admin role: $error');
    }
  }

  Future<void> _safeSignOut() async {
    try {
      await _supabase.signOut();
    } catch (_) {
      // Best-effort session cleanup after failed role verification.
    }
  }
}
