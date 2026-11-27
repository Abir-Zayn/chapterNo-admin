// Aggregated upsert_mcq_batch RPC result across chunked submissions.
// Mirrors the {inserted, updated, total} JSON returned by the PostgREST RPC.
import 'imports/mcq_batch_upsert_result_imports.dart';

class McqBatchUpsertResult extends Equatable {
  const McqBatchUpsertResult({
    required this.inserted,
    required this.updated,
    required this.total,
  });

  factory McqBatchUpsertResult.fromRpcMap(Map<dynamic, dynamic> map) {
    return McqBatchUpsertResult(
      inserted: (map['inserted'] as num?)?.toInt() ?? 0,
      updated: (map['updated'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
    );
  }

  final int inserted;
  final int updated;
  final int total;

  McqBatchUpsertResult merge(McqBatchUpsertResult other) {
    return McqBatchUpsertResult(
      inserted: inserted + other.inserted,
      updated: updated + other.updated,
      total: total + other.total,
    );
  }

  @override
  List<Object?> get props => [inserted, updated, total];
}
