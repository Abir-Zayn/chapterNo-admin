// Root widget wiring RepositoryProvider, BlocProvider, and GoRouter.
// Uses constructor dependency injection without Riverpod or get_it.
import 'app_imports.dart';

class ChapterNoAdminApp extends StatefulWidget {
  const ChapterNoAdminApp({
    super.key,
    required this.envConfig,
    required this.authRepository,
    this.restoreSessionOnInit = true,
  });

  final EnvConfig envConfig;
  final AuthRepository authRepository;
  final bool restoreSessionOnInit;

  @override
  State<ChapterNoAdminApp> createState() => _ChapterNoAdminAppState();
}

class _ChapterNoAdminAppState extends State<ChapterNoAdminApp> {
  late final AuthCubit _authCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(widget.authRepository);
    _appRouter = AppRouter(authCubit: _authCubit, envConfig: widget.envConfig);
    if (widget.restoreSessionOnInit) {
      _authCubit.restoreSession();
    }
  }

  @override
  void dispose() {
    _appRouter.dispose();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: widget.authRepository,
      child: BlocProvider<AuthCubit>.value(
        value: _authCubit,
        child: MaterialApp.router(
          title: 'ChapterNo Admin Dashboard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
