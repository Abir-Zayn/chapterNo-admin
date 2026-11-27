// Typed domain and application failures for ChapterNo Admin Dashboard.
// Maps infrastructure and validation errors into predictable UI messages.
import 'imports/app_failure_imports.dart';

sealed class AppFailure extends Equatable implements Exception {
  const AppFailure(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];

  @override
  String toString() => code == null ? message : '[$code] $message';
}

final class EnvConfigFailure extends AppFailure {
  const EnvConfigFailure(super.message, {super.code, super.statusCode = 500});
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.code, super.statusCode = 401});
}

final class UnauthorizedAdminFailure extends AppFailure {
  const UnauthorizedAdminFailure([
    super.message = 'Access denied. This dashboard is restricted to verified ChapterNo admins.',
  ]) : super(code: 'unauthorized_admin', statusCode: 403);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.code, super.statusCode = 422});
}

final class ConflictFailure extends AppFailure {
  const ConflictFailure(super.message, {super.code, super.statusCode = 409});
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure(super.message, {super.code, super.statusCode = 403});
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message, {super.code, super.statusCode = 404});
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.code, super.statusCode = 503});
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure(super.message, {super.code, super.statusCode = 500});
}
