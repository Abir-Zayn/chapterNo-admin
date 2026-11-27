// PostgREST implementation of BulkImportRepository calling upsert_mcq_batch.
// Maps PostgrestException codes to typed AppFailures for clear UI messages.
import 'imports/supabase_bulk_import_repository_imports.dart';
import '../resource/bulk_import_resources.dart';

final class SupabaseBulkImportRepository implements BulkImportRepository {
  SupabaseBulkImportRepository(this._supabase);

  final SupabaseService _supabase;

  @override
  Future<McqBatchUpsertResult> upsertMcqBatch(
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) {
      return const McqBatchUpsertResult(
        inserted: 0,
        updated: 0,
        total: 0,
      );
    }
    try {
      final result = await _supabase.rpc(
        kUpsertMcqBatchRpcName,
        params: <String, dynamic>{'p_items': items},
      );
      if (result is! Map) {
        throw const UnexpectedFailure(
          'Unexpected response shape from upsert_mcq_batch.',
        );
      }
      return McqBatchUpsertResult.fromRpcMap(result);
    } on AppFailure {
      rethrow;
    } on PostgrestException catch (error) {
      if (error.code == '42501') {
        throw const ForbiddenFailure(
          'Server rejected the import (42501): editors cannot overwrite '
          'published or verified MCQs. Remove those rows or ask a reviewer '
          'or super admin to import them.',
        );
      }
      if (error.code == '22023') {
        throw ValidationFailure('Server validation failed: ${error.message}');
      }
      throw NetworkFailure('Bulk import failed: ${error.message}');
    } catch (error) {
      throw NetworkFailure('Bulk import failed: $error');
    }
  }
}
