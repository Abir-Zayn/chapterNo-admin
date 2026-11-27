// Import barrel for supabase_bulk_import_repository.dart.
// Centralizes the Supabase service, repository contract, and failure types.
export 'package:chapterno_admin/core/error/app_failure.dart';
export 'package:chapterno_admin/core/supabase/supabase_service.dart';
export 'package:chapterno_admin/feature/bulk_import/domain/entities/mcq_batch_upsert_result.dart';
export 'package:chapterno_admin/feature/bulk_import/domain/repositories/bulk_import_repository.dart';
export 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException;
