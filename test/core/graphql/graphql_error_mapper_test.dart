// Unit tests for GraphQLErrorMapper translating pg_graphql errors to AppFailure.
// Verifies status codes and that technical SQL/GraphQL details are never leaked.
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/core/graphql/graphql_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GraphQLErrorMapper', () {
    test('maps Postgres 23505 unique violation to ValidationFailure (409)', () {
      final failure = GraphQLErrorMapper.mapErrors([
        {
          'message': 'duplicate key value violates unique constraint',
          'extensions': {'code': '23505'},
        },
      ]);

      expect(failure, isA<ValidationFailure>());
      expect(failure.statusCode, 409);
      expect(
        failure.message,
        contains('Code or chapter number already exists'),
      );
    });

    test('maps Postgres 23503 FK violation to ConflictFailure (409)', () {
      final failure = GraphQLErrorMapper.mapErrors([
        {
          'message':
              'update or delete on table violates foreign key constraint',
          'extensions': {'code': '23503'},
        },
      ]);

      expect(failure, isA<ConflictFailure>());
      expect(failure.statusCode, 409);
      expect(failure.message, contains('Archive instead'));
    });

    test('maps not-null SQL error to friendly 422 without column leak', () {
      final failure = GraphQLErrorMapper.mapErrors([
        {
          'message': 'null value in column "title_en" of relation "subjects" violates not-null constraint',
        },
      ]);

      expect(failure, isA<ValidationFailure>());
      expect(failure.statusCode, 422);
      expect(failure.message, isNot(contains('title_en')));
      expect(failure.message, isNot(contains('relation')));
    });

    test('maps Postgres 42501 / RLS denial to ForbiddenFailure (403)', () {
      final failure = GraphQLErrorMapper.mapErrors([
        {
          'message':
              'new row violates row-level security policy for table "subjects"',
        },
      ]);

      expect(failure, isA<ForbiddenFailure>());
      expect(failure.statusCode, 403);
      expect(failure.message, contains('permission'));
    });

    test('masks raw GraphQL schema errors behind generic 500 message', () {
      final failure = GraphQLErrorMapper.mapErrors([
        {
          'message':
              'Unknown field "insertIntoSubjectsCollection" on type Mutation',
        },
      ]);

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.statusCode, 500);
      expect(failure.message, isNot(contains('Unknown field')));
      expect(failure.message, isNot(contains('Mutation')));
    });

    test('maps HTTP 401, 403, 404, and 500 to expected status codes', () {
      expect(GraphQLErrorMapper.mapHttpStatus(401, ''), isA<AuthFailure>());
      expect(
        GraphQLErrorMapper.mapHttpStatus(403, ''),
        isA<ForbiddenFailure>(),
      );
      expect(GraphQLErrorMapper.mapHttpStatus(404, ''), isA<NotFoundFailure>());
      final serverFailure = GraphQLErrorMapper.mapHttpStatus(500, '');
      expect(serverFailure, isA<NetworkFailure>());
      expect(serverFailure.statusCode, 500);
    });
  });
}
