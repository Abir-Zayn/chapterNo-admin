// Widget tests for CurriculumScreen role gating and Bangla form submission.
// Verifies super_admin, editor, and reviewer UI controls without network calls.
import 'package:chapterno_admin/config/theme/app_theme.dart';
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/feature/auth/domain/admin_user.dart';
import 'package:chapterno_admin/feature/auth/domain/auth_repository.dart';
import 'package:chapterno_admin/feature/auth/screens/bloc/auth_cubit.dart';
import 'package:chapterno_admin/feature/auth/types/admin_role.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/board.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/chapter.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/curriculum_root.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/education_level.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/subject.dart';
import 'package:chapterno_admin/feature/curriculum/domain/repositories/curriculum_repository.dart';
import 'package:chapterno_admin/feature/curriculum/screens/bloc/curriculum_cubit.dart';
import 'package:chapterno_admin/feature/curriculum/screens/curriculum_screen.dart';
import 'package:chapterno_admin/feature/curriculum/types/academic_group.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockCurriculumRepository extends Mock implements CurriculumRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockCurriculumRepository curriculumRepository;

  const ssc = EducationLevel(
    id: 'lvl-1',
    code: 'ssc',
    nameBn: 'এসএসসি',
    nameEn: 'SSC',
    displayOrder: 1,
    isActive: true,
  );
  const dhaka = Board(
    id: 'brd-1',
    educationLevelId: 'lvl-1',
    code: 'dhaka',
    nameBn: 'ঢাকা',
    nameEn: 'Dhaka',
    displayOrder: 1,
    isActive: true,
  );
  const physics = Subject(
    id: 'sub-1',
    educationLevelId: 'lvl-1',
    code: 'ssc_phy',
    academicGroup: AcademicGroup.science,
    nameBn: 'পদার্থবিজ্ঞান',
    nameEn: 'Physics',
    displayOrder: 1,
    isActive: true,
  );

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    curriculumRepository = _MockCurriculumRepository();
    when(() => curriculumRepository.fetchRoot()).thenAnswer(
      (_) async => const CurriculumRoot(levels: [ssc], boards: [dhaka]),
    );
    when(
      () =>
          curriculumRepository.fetchSubjects(levelId: 'lvl-1', isActive: true),
    ).thenAnswer((_) async => const [physics]);
    when(() => curriculumRepository.fetchChaptersWithTopics(subjectId: 'sub-1'))
        .thenAnswer((_) async => const []);
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    AdminRole role, {
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(1280, 820);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => authRepository.restoreSession()).thenAnswer(
      (_) async => AdminUser(
        userId: 'u-1',
        email: 'admin@chapterno.com',
        displayName: 'Admin',
        role: role,
        isActive: true,
      ),
    );

    final authCubit = AuthCubit(authRepository);
    await authCubit.restoreSession();
    final curriculumCubit = CurriculumCubit(curriculumRepository);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authCubit),
          BlocProvider.value(value: curriculumCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: CurriculumScreen()),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('reviewer sees Read-only banner and no Add buttons', (
    tester,
  ) async {
    await pumpScreen(tester, AdminRole.reviewer);

    expect(find.text('Read-only (Reviewer)'), findsOneWidget);
    expect(find.text('Add Subject'), findsNothing);
    expect(find.text('Add Chapter'), findsNothing);
  });

  testWidgets('editor can add chapter with Bangla UTF-8 title', (tester) async {
    const createdChapter = Chapter(
      id: 'ch-1',
      subjectId: 'sub-1',
      chapterNumber: 1,
      code: 'ssc_phy_physical_quantities',
      nameBn: 'ভৌত রাশি ও পরিমাপ',
      nameEn: 'Physical Quantities',
      displayOrder: 1,
      isActive: true,
    );
    when(
      () => curriculumRepository.createChapter(
        subjectId: 'sub-1',
        chapterNumber: 1,
        code: 'ssc_phy_physical_quantities',
        nameBn: 'ভৌত রাশি ও পরিমাপ',
        nameEn: 'Physical Quantities',
        displayOrder: 1,
        descriptionBn: '',
      ),
    ).thenAnswer((_) async => createdChapter);

    await pumpScreen(tester, AdminRole.editor);

    expect(find.text('Add Subject'), findsOneWidget);
    expect(find.text('Add Chapter'), findsOneWidget);

    await tester.tap(find.text('Add Chapter'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Bangla Name (বাংলা নাম) *'),
      'ভৌত রাশি ও পরিমাপ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'English Name *'),
      'Physical Quantities',
    );
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    verify(
      () => curriculumRepository.createChapter(
        subjectId: 'sub-1',
        chapterNumber: 1,
        code: 'ssc_phy_physical_quantities',
        nameBn: 'ভৌত রাশি ও পরিমাপ',
        nameEn: 'Physical Quantities',
        displayOrder: 1,
        descriptionBn: '',
      ),
    ).called(1);
  });

  testWidgets('editor cannot mutate Boards & Levels', (tester) async {
    await pumpScreen(tester, AdminRole.editor);
    await tester.tap(find.text('Boards & Levels'));
    await tester.pumpAndSettle();
    expect(find.text('Add Level'), findsNothing);
    expect(find.text('Add Board'), findsNothing);
  });

  testWidgets('super_admin can mutate Boards & Levels', (tester) async {
    await pumpScreen(tester, AdminRole.superAdmin);
    await tester.tap(find.text('Boards & Levels'));
    await tester.pumpAndSettle();
    expect(find.text('Add Level'), findsOneWidget);
    expect(find.text('Add Board'), findsOneWidget);
  });

  testWidgets('selected group chip uses white text on black primary fill', (
    tester,
  ) async {
    await pumpScreen(tester, AdminRole.editor);

    final allChipText = tester.widget<Text>(
      find.descendant(of: find.byType(ChoiceChip), matching: find.text('সকল')),
    );
    expect(allChipText.style?.color, Colors.white);

    final scienceFinder = find.descendant(
      of: find.byType(ChoiceChip),
      matching: find.text('বিজ্ঞান'),
    );
    final scienceChipText = tester.widget<Text>(scienceFinder);
    expect(scienceChipText.style?.color, AppColors.textPrimary);

    await tester.tap(scienceFinder);
    await tester.pumpAndSettle();

    final selectedScienceText = tester.widget<Text>(scienceFinder);
    expect(selectedScienceText.style?.color, Colors.white);
  });

  testWidgets('renders status-based error scene and snackbar on 403 failure', (
    tester,
  ) async {
    when(() => curriculumRepository.fetchRoot()).thenAnswer(
      (_) async => throw const ForbiddenFailure(
        'You do not have permission for this action.',
        statusCode: 403,
      ),
    );

    await pumpScreen(tester, AdminRole.editor, settle: false);

    expect(find.text('Access Denied (403)'), findsOneWidget);
    expect(
      find.text('Error 403: You do not have permission for this action.'),
      findsOneWidget,
    );
  });
}
