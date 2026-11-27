// Widget tests for Milestone 1 router guard, login screen, and desktop shell.
// Uses mocked AuthRepository so no live Supabase network calls occur.
import 'package:chapterno_admin/app.dart';
import 'package:chapterno_admin/config/env/env_config.dart';
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/feature/auth/domain/admin_user.dart';
import 'package:chapterno_admin/feature/auth/domain/auth_repository.dart';
import 'package:chapterno_admin/feature/auth/types/admin_role.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/curriculum_root.dart';
import 'package:chapterno_admin/feature/curriculum/domain/repositories/curriculum_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockCurriculumRepository extends Mock implements CurriculumRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late EnvConfig envConfig;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    envConfig = EnvConfig.fromValues(
      supabaseUrl: 'https://test-project.supabase.co',
      supabasePublishableKey: 'sb_publishable_test_key',
    );
  });

  testWidgets('unauthenticated user is routed to LoginScreen', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => authRepository.restoreSession()).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ChapterNoAdminApp(envConfig: envConfig, authRepository: authRepository),
    );
    await tester.pumpAndSettle();

    expect(find.text('ChapterNo Admin'), findsOneWidget);
    expect(find.text('Sign In to Admin Workspace'), findsOneWidget);
  });

  testWidgets('non-admin login shows Unauthorized Account notice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => authRepository.restoreSession()).thenAnswer((_) async => null);
    when(
      () => authRepository.signInWithEmail(
        email: 'student@chapterno.com',
        password: 'password123',
      ),
    ).thenThrow(const UnauthorizedAdminFailure());

    await tester.pumpWidget(
      ChapterNoAdminApp(envConfig: envConfig, authRepository: authRepository),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'student@chapterno.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign In to Admin Workspace'));
    await tester.pumpAndSettle();

    expect(find.text('Unauthorized Account'), findsOneWidget);
    expect(
      find.textContaining('restricted to verified ChapterNo admins'),
      findsOneWidget,
    );
  });

  testWidgets('authenticated admin sees desktop sidebar and navigates', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const admin = AdminUser(
      userId: 'admin-1',
      email: 'lead@chapterno.com',
      displayName: 'Nadia Karim',
      role: AdminRole.superAdmin,
      isActive: true,
    );

    final curriculumRepository = _MockCurriculumRepository();
    when(() => authRepository.restoreSession()).thenAnswer((_) async => admin);
    when(() => curriculumRepository.fetchRoot())
        .thenAnswer((_) async => const CurriculumRoot(levels: [], boards: []));

    await tester.pumpWidget(
      ChapterNoAdminApp(
        envConfig: envConfig,
        authRepository: authRepository,
        curriculumRepository: curriculumRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Curriculum'), findsOneWidget);
    expect(find.text('MCQ Studio'), findsOneWidget);
    expect(find.text('Bulk Import'), findsOneWidget);
    expect(find.text('Question Bank'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Curriculum Catalogue'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Workspace Settings'), findsOneWidget);
    expect(find.text('test-project.supabase.co'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
