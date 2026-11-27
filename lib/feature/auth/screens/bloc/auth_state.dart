// Immutable authentication state consumed by AuthCubit and AppRouter.
// Tracks session check, active admin user, and unauthorized student notices.
import 'auth_state_imports.dart';

enum AuthStatus {
  initial,
  checking,
  authenticated,
  unauthenticated,
  unauthorized,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.adminUser,
    this.errorMessage,
    this.isSubmitting = false,
  });

  final AuthStatus status;
  final AdminUser? adminUser;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && adminUser != null;

  AuthState copyWith({
    AuthStatus? status,
    AdminUser? adminUser,
    bool clearAdminUser = false,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return AuthState(
      status: status ?? this.status,
      adminUser: clearAdminUser ? null : (adminUser ?? this.adminUser),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [status, adminUser, errorMessage, isSubmitting];
}
