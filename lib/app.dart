// Root widget wiring RepositoryProvider, BlocProvider, GoRouter, and the Forui theme.
// Uses constructor dependency injection without Riverpod or get_it.
import 'imports/app_imports.dart';

class ChapterNoAdminApp extends StatefulWidget {
  const ChapterNoAdminApp({
    super.key,
    required this.envConfig,
    required this.authRepository,
    this.curriculumRepository,
    this.bulkImportRepository,
    this.questionBankRepository,
    this.restoreSessionOnInit = true,
  });

  final EnvConfig envConfig;
  final AuthRepository authRepository;
  final CurriculumRepository? curriculumRepository;
  final BulkImportRepository? bulkImportRepository;
  final QuestionBankRepository? questionBankRepository;
  final bool restoreSessionOnInit;

  @override
  State<ChapterNoAdminApp> createState() => _ChapterNoAdminAppState();
}

class _ChapterNoAdminAppState extends State<ChapterNoAdminApp> {
  late final AuthCubit _authCubit;
  late final ThemeCubit _themeCubit;
  CurriculumCubit? _curriculumCubit;
  BulkImportCubit? _bulkImportCubit;
  QuestionBankCubit? _questionBankCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(widget.authRepository);
    _themeCubit = ThemeCubit();
    if (widget.curriculumRepository != null) {
      _curriculumCubit = CurriculumCubit(widget.curriculumRepository!);
    }
    if (widget.curriculumRepository != null &&
        widget.bulkImportRepository != null) {
      _bulkImportCubit = BulkImportCubit(
        widget.bulkImportRepository!,
        widget.curriculumRepository!,
      );
    }
    if (widget.curriculumRepository != null &&
        widget.questionBankRepository != null) {
      _questionBankCubit = QuestionBankCubit(
        widget.questionBankRepository!,
        widget.curriculumRepository!,
      );
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
    _bulkImportCubit?.close();
    _questionBankCubit?.close();
    _themeCubit.close();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: 'ChapterNo Admin Dashboard',
          debugShowCheckedModeBanner: false,
          supportedLocales: FLocalizations.supportedLocales,
          localizationsDelegates: const [...FLocalizations.localizationsDelegates],
          theme: lightTheme.toApproximateMaterialTheme(),
          darkTheme: darkTheme.toApproximateMaterialTheme(),
          themeMode: themeMode,
          routerConfig: _appRouter.router,
          builder: (context, child) => FTheme(
            data: Theme.brightnessOf(context) == Brightness.light
                ? lightTheme
                : darkTheme,
            child: FToaster(child: FTooltipGroup(child: child!)),
          ),
        );
      },
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        if (widget.curriculumRepository != null)
          RepositoryProvider<CurriculumRepository>.value(
            value: widget.curriculumRepository!,
          ),
        if (widget.bulkImportRepository != null)
          RepositoryProvider<BulkImportRepository>.value(
            value: widget.bulkImportRepository!,
          ),
        if (widget.questionBankRepository != null)
          RepositoryProvider<QuestionBankRepository>.value(
            value: widget.questionBankRepository!,
          ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<ThemeCubit>.value(value: _themeCubit),
          if (_curriculumCubit != null)
            BlocProvider<CurriculumCubit>.value(value: _curriculumCubit!),
          if (_bulkImportCubit != null)
            BlocProvider<BulkImportCubit>.value(value: _bulkImportCubit!),
          if (_questionBankCubit != null)
            BlocProvider<QuestionBankCubit>.value(value: _questionBankCubit!),
        ],
        child: app,
      ),
    );
  }
}
