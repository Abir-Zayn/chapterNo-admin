// Minimal Flutter entrypoint delegating startup to crash-safe bootstrap().
// Requires --dart-define-from-file=.env with SUPABASE_URL and PUBLISHABLE_KEY.
import 'main_imports.dart';

Future<void> main() async {
  await bootstrap();
}
