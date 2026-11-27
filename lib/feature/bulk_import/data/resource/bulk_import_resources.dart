// Static resource constants for the bulk importer data layer.
// Names the PostgREST RPC exactly as created in migration 0003.

/// PostgREST RPC name (NOT a pg_graphql field; string-encoded JSON issues).
const String kUpsertMcqBatchRpcName = 'upsert_mcq_batch';
