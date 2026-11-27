// Pure-Dart GraphQL payload and response helpers for Curriculum repositories.
// Handles archive patches, nullable trimming, and pg_graphql edge/record parsing.
import 'imports/curriculum_graphql_helpers_imports.dart';

abstract final class CurriculumGraphQLHelpers {
  static Map<String, dynamic> archivePatch(bool isActive) {
    return {
      'isActive': isActive,
      'archivedAt': isActive ? null : DateTime.now().toUtc().toIso8601String(),
    };
  }

  static String? nullableTrim(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<T> parseEdges<T>(
    dynamic collection,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (collection is! Map || collection['edges'] is! List) return [];
    final results = <T>[];
    for (final edge in collection['edges'] as List) {
      if (edge is Map && edge['node'] is Map) {
        results.add(fromJson(Map<String, dynamic>.from(edge['node'] as Map)));
      }
    }
    return results;
  }

  static T parseFirstRecord<T>(
    dynamic mutationResult,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    assertAffected(mutationResult);
    final records = (mutationResult as Map)['records'];
    if (records is! List || records.isEmpty || records.first is! Map) {
      throw const UnexpectedFailure('GraphQL mutation returned no records.');
    }
    return fromJson(Map<String, dynamic>.from(records.first as Map));
  }

  static void assertAffected(dynamic mutationResult) {
    if (mutationResult is! Map) {
      throw const UnexpectedFailure('Invalid GraphQL mutation response.');
    }
    final affected = (mutationResult['affectedCount'] as num?)?.toInt() ?? 0;
    if (affected == 0) {
      throw const NotFoundFailure('Record not found or access denied.');
    }
  }
}
