// Import barrel for bootstrap.dart.
// Centralizes zone error handling, Supabase init, auth repository, and root app.
export 'dart:async';
export 'dart:ui' show PlatformDispatcher;

export 'package:chapterno_admin/app.dart';
export 'package:chapterno_admin/config/env/env_config.dart';
export 'package:chapterno_admin/config/theme/app_theme.dart';
export 'package:chapterno_admin/core/error/app_failure.dart';
export 'package:chapterno_admin/core/supabase/supabase_service.dart';
export 'package:chapterno_admin/feature/auth/data/supabase_auth_repository.dart';
export 'package:chapterno_admin/shared/widgets/state_views.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:material_ui/material_ui.dart';
export 'package:supabase_flutter/supabase_flutter.dart';
