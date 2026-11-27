// Application router with server-verified admin role guard and desktop ShellRoute.
// Redirects non-admins and unauthenticated users to /login immediately.
import 'app_router_imports.dart';

class AppRouter {
  AppRouter({required AuthCubit authCubit, required this._envConfig})
    : _authCubit = authCubit,
      _refreshListenable = _CubitRefreshNotifier(authCubit.stream) {
    router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: _refreshListenable,
      redirect: _handleRedirect,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, _) => const Scaffold(
            body: AppLoadingView(message: 'Verifying admin session...'),
          ),
        ),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        ShellRoute(
          builder: (context, state, child) {
            final admin = _authCubit.state.adminUser;
            if (admin == null) {
              return const Scaffold(
                body: AppLoadingView(message: 'Checking permissions...'),
              );
            }
            return AdminShell(
              currentPath: state.uri.path,
              adminUser: admin,
              onSignOut: _authCubit.signOut,
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/curriculum',
              builder: (_, _) => const CurriculumScreen(),
            ),
            GoRoute(
              path: '/mcq-studio',
              builder: (_, _) => const MilestonePlaceholderScreen(
                title: 'Bangla MCQ Studio',
                milestoneCode: 'Milestone 3',
                description: 'Author Simple, Multiple-Completion (i, ii, iii), and Stimulus MCQs in UTF-8 Bangla with a live 360dp student preview.',
                icon: PhosphorIconsRegular.pencilSimpleLine,
              ),
            ),
            GoRoute(
              path: '/bulk-import',
              builder: (_, _) => const MilestonePlaceholderScreen(
                title: 'Bulk CSV / JSON Importer',
                milestoneCode: 'Milestone 4',
                description: 'Validate UTF-8 Google Sheets exports, reject legacy Bijoy ANSI text, preview row errors, and batch-upsert via external_code.',
                icon: PhosphorIconsRegular.fileCsv,
              ),
            ),
            GoRoute(
              path: '/question-bank',
              builder: (_, _) => const MilestonePlaceholderScreen(
                title: 'Question Bank Browser',
                milestoneCode: 'Milestone 5',
                description: 'Paginated search and multi-axis filtering across Subject, Chapter, Topic, Board, Year, Source, Difficulty, and Rights Status.',
                icon: PhosphorIconsRegular.database,
              ),
            ),
            GoRoute(
              path: '/settings',
              builder: (_, _) => SettingsScreen(envConfig: _envConfig),
            ),
          ],
        ),
      ],
    );
  }

  final AuthCubit _authCubit;
  final EnvConfig _envConfig;
  final _CubitRefreshNotifier _refreshListenable;
  late final GoRouter router;

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = _authCubit.state;
    final location = state.uri.path;

    final isBootstrapping =
        authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.checking;

    if (isBootstrapping) {
      return location == '/splash' ? null : '/splash';
    }

    if (!authState.isAuthenticated) {
      return location == '/login' ? null : '/login';
    }

    if (location == '/login' || location == '/splash' || location == '/') {
      return '/curriculum';
    }

    return null;
  }

  void dispose() {
    _refreshListenable.dispose();
    router.dispose();
  }
}

class _CubitRefreshNotifier extends ChangeNotifier {
  _CubitRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
