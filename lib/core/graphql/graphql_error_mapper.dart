// Maps Supabase pg_graphql errors[] and HTTP status codes into AppFailure.
// Translates technical Postgres/GraphQL errors into user-safe messages & codes.
import 'imports/graphql_error_mapper_imports.dart';

abstract final class GraphQLErrorMapper {
  static AppFailure mapErrors(List<dynamic> errors) {
    if (errors.isEmpty) {
      return const UnexpectedFailure(
        'Something went wrong while processing your request. Please try again.',
        code: 'server_error',
        statusCode: 500,
      );
    }

    final first = errors.first;
    final message = first is Map
        ? (first['message'] ?? '').toString()
        : first.toString();
    final extensions = first is Map && first['extensions'] is Map
        ? Map<String, dynamic>.from(first['extensions'] as Map)
        : const <String, dynamic>{};
    final code = (extensions['code'] ?? '').toString();
    final lower = message.toLowerCase();

    if (code == '23505' ||
        lower.contains('duplicate key') ||
        lower.contains('23505') ||
        lower.contains('unique constraint')) {
      return const ValidationFailure(
        'Code or chapter number already exists.',
        code: '23505',
        statusCode: 409,
      );
    }

    if (code == '23503' ||
        lower.contains('foreign key') ||
        lower.contains('23503') ||
        lower.contains('violates foreign key')) {
      return const ConflictFailure(
        'Cannot delete because dependent chapters, topics, or questions exist. Archive instead.',
        code: '23503',
        statusCode: 409,
      );
    }

    if (code == '23502' ||
        code == '23514' ||
        code == '22P02' ||
        lower.contains('not-null constraint') ||
        lower.contains('check constraint') ||
        lower.contains('invalid input syntax')) {
      return const ValidationFailure(
        'Some required fields are missing or invalid. Please check your input and try again.',
        code: 'validation_error',
        statusCode: 422,
      );
    }

    if (code == '42501' ||
        lower.contains('42501') ||
        lower.contains('permission denied') ||
        lower.contains('row-level security') ||
        lower.contains('insufficient role') ||
        lower.contains('forbidden')) {
      return const ForbiddenFailure(
        'You do not have permission for this action.',
        code: '42501',
        statusCode: 403,
      );
    }

    return UnexpectedFailure(
      'Something went wrong while saving your changes. Please try again.',
      code: code.isEmpty ? 'server_error' : code,
      statusCode: 500,
    );
  }

  static AppFailure mapHttpStatus(int statusCode, String body) {
    if (statusCode == 401) {
      return const AuthFailure(
        'Your session has expired. Please sign in again.',
        code: 'http_401',
        statusCode: 401,
      );
    }
    if (statusCode == 403) {
      return const ForbiddenFailure(
        'You do not have permission for this action.',
        code: 'http_403',
        statusCode: 403,
      );
    }
    if (statusCode == 404) {
      return const NotFoundFailure(
        'The requested curriculum resource could not be found.',
        code: 'http_404',
        statusCode: 404,
      );
    }
    if (statusCode == 409) {
      return const ConflictFailure(
        'This update conflicts with an existing record.',
        code: 'http_409',
        statusCode: 409,
      );
    }
    if (statusCode == 400 || statusCode == 422) {
      return ValidationFailure(
        'Please check your input and try again.',
        code: 'http_$statusCode',
        statusCode: statusCode,
      );
    }
    return NetworkFailure(
      'Unable to reach the server right now. Please try again.',
      code: 'http_$statusCode',
      statusCode: statusCode,
    );
  }
}
