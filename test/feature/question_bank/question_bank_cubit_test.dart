import 'package:bloc_test/bloc_test.dart';
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/board.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/chapter.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/curriculum_root.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/education_level.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/subject.dart';
import 'package:chapterno_admin/feature/curriculum/domain/repositories/curriculum_repository.dart';
import 'package:chapterno_admin/feature/curriculum/types/academic_group.dart';
import 'package:chapterno_admin/feature/question_bank/domain/entities/mcq_question.dart';
import 'package:chapterno_admin/feature/question_bank/domain/repositories/question_bank_repository.dart';
import 'package:chapterno_admin/feature/question_bank/screens/bloc/question_bank_cubit.dart';
import 'package:chapterno_admin/feature/question_bank/screens/bloc/question_bank_state.dart';
import 'package:chapterno_admin/feature/question_bank/types/question_bank_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockQuestionBankRepository extends Mock
    implements QuestionBankRepository {}

class _MockCurriculumRepository extends Mock implements CurriculumRepository {}

final _sampleLevel = EducationLevel(
  id: 'lvl-1',
  code: 'ssc',
  nameBn: 'এসএসসি',
  nameEn: 'SSC',
  displayOrder: 1,
  isActive: true,
);

final _sampleBoard = Board(
  id: 'brd-1',
  educationLevelId: 'lvl-1',
  code: 'dhaka',
  nameBn: 'ঢাকা',
  nameEn: 'Dhaka',
  displayOrder: 1,
  isActive: true,
);

final _sampleSubject = Subject(
  id: '1',
  educationLevelId: 'lvl-1',
  code: 'phy',
  academicGroup: AcademicGroup.science,
  nameBn: 'পদার্থবিজ্ঞান',
  nameEn: 'Physics',
  displayOrder: 1,
  isActive: true,
);

final _sampleChapter = Chapter(
  id: '2',
  subjectId: '1',
  chapterNumber: 2,
  code: 'ch02',
  nameBn: 'গতি',
  nameEn: 'Motion',
  displayOrder: 2,
  isActive: true,
);

final _sampleQuestion = McqQuestion(
  id: 'q-1',
  externalCode: 'SSC-PHY-CH02-001',
  subjectId: 1,
  chapterId: 2,
  questionType: McqQuestionType.simple,
  title: 'স্থির বস্তুর অবস্থাকে কী বলে?',
  options: const [
    McqOption(key: '1', text: 'স্থিতি'),
    McqOption(key: '2', text: 'গতি'),
  ],
  correctOption: '1',
  difficulty: McqDifficulty.l1,
  sourceType: McqSourceType.curated,
  rightsStatus: McqRightsStatus.internal,
  status: McqStatus.draft,
  isVerified: false,
  version: 1,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  setUpAll(() {
    registerFallbackValue(const QuestionBankFilter());
    registerFallbackValue(QuestionBankModerationAction.approveAndPublish);
  });

  late _MockQuestionBankRepository questionRepo;
  late _MockCurriculumRepository curriculumRepo;

  setUp(() {
    questionRepo = _MockQuestionBankRepository();
    curriculumRepo = _MockCurriculumRepository();

    when(() => curriculumRepo.fetchRoot()).thenAnswer(
      (_) async => CurriculumRoot(
        levels: [_sampleLevel],
        boards: [_sampleBoard],
      ),
    );
    when(
      () => curriculumRepo.fetchSubjects(levelId: 'lvl-1', isActive: true),
    ).thenAnswer((_) async => [_sampleSubject]);
    when(
      () => curriculumRepo.fetchChaptersWithTopics(subjectId: '1'),
    ).thenAnswer((_) async => [_sampleChapter]);
    when(() => questionRepo.fetchQuestions(any())).thenAnswer(
      (invocation) async {
        final filter = invocation.positionalArguments.first as QuestionBankFilter;
        return QuestionBankPage(
          items: [_sampleQuestion],
          totalCount: 50,
          page: filter.page,
          pageSize: filter.pageSize,
        );
      },
    );
  });

  group('QuestionBankCubit', () {
    blocTest<QuestionBankCubit, QuestionBankState>(
      'initialize loads curriculum context and first page of questions',
      build: () => QuestionBankCubit(questionRepo, curriculumRepo),
      act: (cubit) => cubit.initialize(),
      verify: (cubit) {
        expect(cubit.state.status, QuestionBankLoadStatus.ready);
        expect(cubit.state.levels, [_sampleLevel]);
        expect(cubit.state.subjects, [_sampleSubject]);
        expect(cubit.state.items, [_sampleQuestion]);
        expect(cubit.state.totalCount, 50);
        expect(cubit.state.totalPages, 2);
      },
    );

    blocTest<QuestionBankCubit, QuestionBankState>(
      'selectSubject loads chapters and refetches page 1 with subjectId filter',
      build: () => QuestionBankCubit(questionRepo, curriculumRepo),
      act: (cubit) async {
        await cubit.initialize();
        await cubit.selectSubject(1);
      },
      verify: (cubit) {
        expect(cubit.state.filter.subjectId, 1);
        expect(cubit.state.chapters, [_sampleChapter]);
        verify(
          () => questionRepo.fetchQuestions(
            const QuestionBankFilter(subjectId: 1, page: 1),
          ),
        ).called(1);
      },
    );

    blocTest<QuestionBankCubit, QuestionBankState>(
      'goToPage requests page 2 and clears selection',
      build: () => QuestionBankCubit(questionRepo, curriculumRepo),
      act: (cubit) async {
        await cubit.initialize();
        cubit.toggleSelection('q-1');
        await cubit.goToPage(2);
      },
      verify: (cubit) {
        expect(cubit.state.filter.page, 2);
        expect(cubit.state.selectedIds, isEmpty);
      },
    );

    blocTest<QuestionBankCubit, QuestionBankState>(
      'applyModeration calls repository, clears selection, sets feedback, and refreshes page',
      setUp: () {
        when(
          () => questionRepo.updateQuestionsStatus(
            questionIds: any(named: 'questionIds'),
            action: any(named: 'action'),
          ),
        ).thenAnswer((_) async {});
      },
      build: () => QuestionBankCubit(questionRepo, curriculumRepo),
      act: (cubit) async {
        await cubit.initialize();
        cubit.toggleSelection('q-1');
        final ok = await cubit.applyModeration(
          questionIds: ['q-1'],
          action: QuestionBankModerationAction.approveAndPublish,
        );
        expect(ok, isTrue);
      },
      verify: (cubit) {
        expect(cubit.state.selectedIds, isEmpty);
        expect(cubit.state.feedbackMessage, 'Published & verified question.');
        verify(
          () => questionRepo.updateQuestionsStatus(
            questionIds: ['q-1'],
            action: QuestionBankModerationAction.approveAndPublish,
          ),
        ).called(1);
      },
    );

    blocTest<QuestionBankCubit, QuestionBankState>(
      'surfaces ForbiddenFailure when moderation is rejected by RLS',
      setUp: () {
        when(
          () => questionRepo.updateQuestionsStatus(
            questionIds: any(named: 'questionIds'),
            action: any(named: 'action'),
          ),
        ).thenThrow(const ForbiddenFailure('Permission denied (42501)'));
      },
      build: () => QuestionBankCubit(questionRepo, curriculumRepo),
      act: (cubit) async {
        await cubit.initialize();
        final ok = await cubit.applyModeration(
          questionIds: ['q-1'],
          action: QuestionBankModerationAction.approveAndPublish,
        );
        expect(ok, isFalse);
      },
      verify: (cubit) {
        expect(cubit.state.errorMessage, contains('42501'));
        expect(cubit.state.errorStatusCode, 403);
      },
    );
  });
}
