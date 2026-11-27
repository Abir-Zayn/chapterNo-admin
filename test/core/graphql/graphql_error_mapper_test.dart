// Unit tests for GraphQLErrorMapper translating pg_graphql errors to AppFailure.
// Covers 23505 unique, 23503 FK, 42501 RLS, and HTTP status error mappings.
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/core/graphql/graphql_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GraphQLErrorMapper', () {
    test('maps Postgres 23505 unique violation to ValidationFailure', () {
      final failure = GraphQLErrorMapper.mapErrors([
        {
          'message': 'duplicate key value violates unique constraint',
          'extensions': {'code': '23505'},
        },
      ]);

      expect(failure, isA<ValidationFailure>());
      expect(
        failure.message,
        contains('Code or chapter number already exists'),
      );
    });

    test('maps Postgres 23503 FK violation to ConflictFailure', () {
      final failure = GraphQLErrorMapper.mapErrors([
        {
          'message':
              'update or delete on table violates foreign key constraint',
          'extensions': {'code': '23503'},
        },
      ]);

      expect(failure, isA<ConflictFailure>());
      expect(failure.message, contains('Archive instead'));
    });

    test('maps Postgres 42501 / RLS denial to ForbiddenFailure', () {
      final failure = GraphQLErrorMapper.mapErrors([
        {
          'message':
              'new row violates row-level security policy for table "subjects"',
        },
      ]);

      expect(failure, isA<ForbiddenFailure>());
      expect(failure.message, contains('permission'));
    });

    test('maps HTTP 403 to ForbiddenFailure and 500 to NetworkFailure', () {
      expect(
        GraphQLErrorMapper.mapHttpStatus(403, ''),
        isA<ForbiddenFailure>(),
      );
      expect(GraphQLErrorMapper.mapHttpStatus(500, ''), isA<NetworkFailure>());
    });
  });
}
