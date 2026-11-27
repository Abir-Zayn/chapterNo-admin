// Crash-safe application bootstrap handling env validation and Supabase init.
// Renders an actionable configuration error screen if .env defines are invalid.
import 'bootstrap_imports.dart';

Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Uncaught platform error: $error\n$stack');
        return true;
      };

      Bloc.observer = const _AppBlocObserver();

      late final EnvConfig envConfig;
      try {
        envConfig = EnvConfig.fromEnvironment();
      } on EnvConfigFailure catch (failure) {
        runApp(_BootstrapErrorApp(message: failure.message));
        return;
      }

      try {
        await Supabase.initialize(
          url: envConfig.supabaseUrl,
          publishableKey: envConfig.supabasePublishableKey,
        );
      } catch (error) {
        runApp(
          _BootstrapErrorApp(
            message: 'Failed to initialize Supabase client: $error',
          ),
        );
        return;
      }

      final supabaseService = LiveSupabaseService(Supabase.instance.client);
      final authRepository = SupabaseAuthRepository(supabaseService);
      final graphqlService = SupabaseGraphQLService(
        envConfig: envConfig,
        supabaseService: supabaseService,
      );
      final curriculumRepository = GraphQLCurriculumRepository(graphqlService);

      runApp(
        ChapterNoAdminApp(
          envConfig: envConfig,
          authRepository: authRepository,
          curriculumRepository: curriculumRepository,
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}

class _AppBlocObserver extends BlocObserver {
  const _AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('Bloc error in ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }
}

class _BootstrapErrorApp extends StatelessWidget {
  const _BootstrapErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AppErrorBanner(
                title: 'Configuration Error',
                message: message,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
