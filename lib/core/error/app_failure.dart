// Typed domain and application failures for ChapterNo Admin Dashboard.
// Maps infrastructure and validation errors into predictable UI messages.
import 'app_failure_imports.dart';

sealed class AppFailure extends Equatable implements Exception {
  const AppFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => code == null ? message : '[$code] $message';
}

final class EnvConfigFailure extends AppFailure {
  const EnvConfigFailure(super.message, {super.code});
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.code});
}

final class UnauthorizedAdminFailure extends AppFailure {
  const UnauthorizedAdminFailure([
    super.message = 'Access denied. This dashboard is restricted to verified ChapterNo admins.',
  ]) : super(code: 'unauthorized_admin');
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.code});
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.code});
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message, {super.code});
}
