// Import barrel for supabase_auth_repository.dart.
// Connects domain auth contracts to SupabaseService and typed failures.
export 'package:chapterno_admin/core/error/app_failure.dart';
export 'package:chapterno_admin/core/supabase/supabase_service.dart';
export 'package:chapterno_admin/feature/auth/domain/admin_user.dart';
export 'package:chapterno_admin/feature/auth/domain/auth_repository.dart';
export 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, PostgrestException;
