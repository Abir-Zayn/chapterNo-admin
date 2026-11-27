// Abstract repository contract for the bulk MCQ importer.
// Keeps the Cubit layer decoupled from PostgREST RPC details.
import 'imports/bulk_import_repository_imports.dart';

abstract interface class BulkImportRepository {
  /// Calls public.upsert_mcq_batch with raw payload items and returns the
  /// server-computed {inserted, updated, total} summary.
  Future<McqBatchUpsertResult> upsertMcqBatch(
    List<Map<String, dynamic>> items,
  );
}
