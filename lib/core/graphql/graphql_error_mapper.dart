// Maps Supabase pg_graphql errors[] and HTTP status codes into AppFailure.
// Translates Postgres 23505, 23503, and 42501 into clear admin messages.
import 'imports/graphql_error_mapper_imports.dart';

abstract final class GraphQLErrorMapper {
  static AppFailure mapErrors(List<dynamic> errors) {
    if (errors.isEmpty) {
      return const UnexpectedFailure('Unknown GraphQL error occurred.');
    }

    final first = errors.first;
    final message = first is Map
        ? (first['message'] ?? 'GraphQL request failed.').toString()
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
      );
    }

    if (code == '23503' ||
        lower.contains('foreign key') ||
        lower.contains('23503') ||
        lower.contains('violates foreign key')) {
      return const ConflictFailure(
        'Cannot delete because dependent chapters, topics, or questions exist. Archive instead.',
        code: '23503',
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
      );
    }

    return UnexpectedFailure(message, code: code.isEmpty ? null : code);
  }

  static AppFailure mapHttpStatus(int statusCode, String body) {
    if (statusCode == 401 || statusCode == 403) {
      return const ForbiddenFailure(
        'You do not have permission for this action.',
        code: 'http_forbidden',
      );
    }
    return NetworkFailure(
      'GraphQL request failed (HTTP $statusCode).',
      code: 'http_$statusCode',
    );
  }
}
