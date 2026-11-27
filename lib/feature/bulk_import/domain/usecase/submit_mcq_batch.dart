// Use case: submit valid MCQ payloads in safe chunks to upsert_mcq_batch.
// Reports chunk progress back to the Cubit for progress UI.
import 'imports/submit_mcq_batch_imports.dart';

class SubmitMcqBatchUseCase {
  const SubmitMcqBatchUseCase(this._repository, {this.chunkSize = 100});

  static const int defaultChunkSize = 100;

  final BulkImportRepository _repository;

  /// Rows per RPC call; keeps each request body small and retryable.
  final int chunkSize;

  Future<McqBatchUpsertResult> call(
    List<Map<String, dynamic>> items, {
    void Function(int chunksDone, int chunksTotal)? onProgress,
  }) async {
    if (items.isEmpty) {
      return const McqBatchUpsertResult(
        inserted: 0,
        updated: 0,
        total: 0,
      );
    }
    final chunks = <List<Map<String, dynamic>>>[];
    for (var start = 0; start < items.length; start += chunkSize) {
      final end =
          start + chunkSize > items.length ? items.length : start + chunkSize;
      chunks.add(items.sublist(start, end));
    }
    var result = const McqBatchUpsertResult(
      inserted: 0,
      updated: 0,
      total: 0,
    );
    for (final (index, chunk) in chunks.indexed) {
      final chunkResult = await _repository.upsertMcqBatch(chunk);
      result = result.merge(chunkResult);
      onProgress?.call(index + 1, chunks.length);
    }
    return McqBatchUpsertResult(
      inserted: result.inserted,
      updated: result.updated,
      total: items.length,
    );
  }
}
