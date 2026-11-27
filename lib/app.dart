// Root widget wiring RepositoryProvider, BlocProvider, and GoRouter.
// Uses constructor dependency injection without Riverpod or get_it.
import 'app_imports.dart';

class ChapterNoAdminApp extends StatefulWidget {
  const ChapterNoAdminApp({
    super.key,
    required this.envConfig,
    required this.authRepository,
    this.curriculumRepository,
    this.restoreSessionOnInit = true,
  });

  final EnvConfig envConfig;
  final AuthRepository authRepository;
  final CurriculumRepository? curriculumRepository;
  final bool restoreSessionOnInit;

  @override
  State<ChapterNoAdminApp> createState() => _ChapterNoAdminAppState();
}

class _ChapterNoAdminAppState extends State<ChapterNoAdminApp> {
  late final AuthCubit _authCubit;
  CurriculumCubit? _curriculumCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(widget.authRepository);
    if (widget.curriculumRepository != null) {
      _curriculumCubit = CurriculumCubit(widget.curriculumRepository!);
    }
    _appRouter = AppRouter(authCubit: _authCubit, envConfig: widget.envConfig);
    if (widget.restoreSessionOnInit) {
      _authCubit.restoreSession();
    }
  }

  @override
  void dispose() {
    _appRouter.dispose();
    _curriculumCubit?.close();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      title: 'ChapterNo Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _appRouter.router,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        if (widget.curriculumRepository != null)
          RepositoryProvider<CurriculumRepository>.value(
            value: widget.curriculumRepository!,
          ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          if (_curriculumCubit != null)
            BlocProvider<CurriculumCubit>.value(value: _curriculumCubit!),
        ],
        child: app,
      ),
    );
  }
}
