// BulkImportCubit tests: context loading, parse+validate, chunked submit,
// and the 42501 editor review-gate failure path.
import 'package:bloc_test/bloc_test.dart';
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/feature/bulk_import/domain/entities/mcq_batch_upsert_result.dart';
import 'package:chapterno_admin/feature/bulk_import/domain/entities/mcq_row_draft.dart';
import 'package:chapterno_admin/feature/bulk_import/domain/repositories/bulk_import_repository.dart';
import 'package:chapterno_admin/feature/bulk_import/screens/bloc/bulk_import_cubit.dart';
import 'package:chapterno_admin/feature/bulk_import/screens/bloc/bulk_import_state.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/board.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/chapter.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/curriculum_root.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/education_level.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/subject.dart';
import 'package:chapterno_admin/feature/curriculum/domain/repositories/curriculum_repository.dart';
import 'package:chapterno_admin/feature/curriculum/types/academic_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBulkImportRepository extends Mock
    implements BulkImportRepository {}

class _MockCurriculumRepository extends Mock
    implements CurriculumRepository {}

const _level = EducationLevel(
  id: '1',
  code: 'ssc',
  nameBn: 'এসএসসি',
  nameEn: 'SSC',
  displayOrder: 1,
  isActive: true,
);

const _subject = Subject(
  id: '53',
  educationLevelId: '1',
  code: 'phy',
  academicGroup: AcademicGroup.science,
  nameBn: 'পদার্থবিজ্ঞান',
  nameEn: 'Physics',
  displayOrder: 1,
  isActive: true,
);

final _chapter = Chapter(
  id: '101',
  subjectId: '53',
  chapterNumber: 1,
  code: 'ch01',
  nameBn: 'অধ্যায় ১',
  nameEn: 'Chapter 1',
  displayOrder: 1,
  isActive: true,
);

const _board = Board(
  id: 'b1111111-1111-4111-8111-111111111111',
  educationLevelId: '1',
  code: 'dhaka',
  nameBn: 'ঢাকা',
  nameEn: 'Dhaka',
  displayOrder: 1,
  isActive: true,
);

const _csvSource =
    'external_code,title,option_1,option_2,option_3,option_4,'
    'correct_ans,level,explanation,chapter_code,exam_year\n'
    'SMK-1,কোনটি সঠিক?,১০,২০,৩০,৪০,2,l4,ব্যাখ্যা,ch01,2025\n';

void main() {
  late _MockBulkImportRepository importRepository;
  late _MockCurriculumRepository curriculumRepository;

  setUp(() {
    importRepository = _MockBulkImportRepository();
    curriculumRepository = _MockCurriculumRepository();
  });

  BulkImportCubit buildCubit() => BulkImportCubit(
    importRepository,
    curriculumRepository,
  );

  void stubHappyContext() {
    when(
      () => curriculumRepository.fetchRoot(),
    ).thenAnswer((_) async => const CurriculumRoot(levels: [_level], boards: [_board]));
    when(
      () => curriculumRepository.fetchSubjects(levelId: '1', isActive: true),
    ).thenAnswer((_) async => [_subject]);
    when(
      () => curriculumRepository.fetchChaptersWithTopics(subjectId: '53'),
    ).thenAnswer((_) async => [_chapter]);
  }

  group('BulkImportCubit.loadContext', () {
    blocTest<BulkImportCubit, BulkImportState>(
      'loads level, subject, and chapters',
      build: () {
        stubHappyContext();
        return buildCubit();
      },
      act: (cubit) => cubit.loadContext(),
      expect: () => [
        isA<BulkImportState>()
            .having((s) => s.status, 'status', BulkImportStatus.loading),
        isA<BulkImportState>()
            .having((s) => s.status, 'status', BulkImportStatus.ready)
            .having((s) => s.selectedLevelId, 'levelId', '1')
            .having((s) => s.levels, 'levels', hasLength(1)),
        isA<BulkImportState>()
            .having((s) => s.subjects, 'subjects', hasLength(1)),
        isA<BulkImportState>()
            .having((s) => s.selectedSubjectId, 'subjectId', '53')
            .having((s) => s.isLoadingChapters, 'loadingChapters', true),
        isA<BulkImportState>()
            .having((s) => s.chapters, 'chapters', hasLength(1))
            .having((s) => s.isLoadingChapters, 'loadingChapters', false),
      ],
    );

    blocTest<BulkImportCubit, BulkImportState>(
      'emits error status when the curriculum fetch fails',
      build: () {
        when(
          () => curriculumRepository.fetchRoot(),
        ).thenThrow(const NetworkFailure('Supabase unreachable'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadContext(),
      expect: () => [
        isA<BulkImportState>()
            .having((s) => s.status, 'status', BulkImportStatus.loading),
        isA<BulkImportState>()
            .having((s) => s.status, 'status', BulkImportStatus.error)
            .having((s) => s.errorMessage, 'message', 'Supabase unreachable'),
      ],
    );
  });

  group('BulkImportCubit.parseSourceText', () {
    blocTest<BulkImportCubit, BulkImportState>(
      'parses pasted CSV and validates rows against loaded chapters',
      build: () => buildCubit(),
      seed: () => const BulkImportState(
        status: BulkImportStatus.ready,
        selectedLevelId: '1',
        selectedSubjectId: '53',
      ).copyWith(chapters: [_chapter]),
      act: (cubit) {
        cubit.updateSourceText(_csvSource);
        cubit.parseSourceText();
      },
      verify: (cubit) {
        expect(cubit.state.rows, hasLength(1));
        expect(cubit.state.rows.single.isValid, isTrue);
        expect(cubit.state.rows.single.resolvedChapterId, 101);
        expect(cubit.state.totalRows, 1);
        expect(cubit.state.validRowCount, 1);
        expect(cubit.state.errorRowCount, 0);
      },
    );

    blocTest<BulkImportCubit, BulkImportState>(
      'reports a 422 validation error for a headerless CSV',
      build: () => buildCubit(),
      seed: () => const BulkImportState(
        status: BulkImportStatus.ready,
        selectedLevelId: '1',
        selectedSubjectId: '53',
      ).copyWith(chapters: [_chapter]),
      act: (cubit) {
        cubit.updateSourceText('not,a,valid,header');
        cubit.parseSourceText();
      },
      verify: (cubit) {
        expect(cubit.state.rows, isEmpty);
        expect(cubit.state.errorStatusCode, 422);
        expect(cubit.state.errorMessage, isNotNull);
      },
    );
  });

  group('BulkImportCubit.submitValidRows', () {
    McqRowDraft validDraft() => McqRowDraft(
      rowNumber: 1,
      externalCode: 'SMK-1',
      title: 'কোনটি সঠিক?',
      options: const [
        McqOptionDraft(key: '1', text: '১০'),
        McqOptionDraft(key: '2', text: '২০'),
        McqOptionDraft(key: '3', text: '৩০'),
        McqOptionDraft(key: '4', text: '৪০'),
      ],
      correctAns: '2',
      level: 'l4',
      resolvedChapterId: 101,
    );

    blocTest<BulkImportCubit, BulkImportState>(
      'submits valid rows and reports the upsert summary',
      build: () {
        when(
          () => importRepository.upsertMcqBatch(any()),
        ).thenAnswer(
          (_) async =>
              const McqBatchUpsertResult(inserted: 1, updated: 0, total: 1),
        );
        return buildCubit();
      },
      seed: () => const BulkImportState(
        status: BulkImportStatus.ready,
        selectedLevelId: '1',
        selectedSubjectId: '53',
      ).copyWith(subjects: [_subject], chapters: [_chapter], rows: [validDraft()]),
      act: (cubit) => cubit.submitValidRows(),
      expect: () => [
        isA<BulkImportState>()
            .having(
              (s) => s.submitPhase,
              'phase',
              BulkImportSubmitPhase.submitting,
            ),
        isA<BulkImportState>()
            .having(
              (s) => s.submitPhase,
              'phase',
              BulkImportSubmitPhase.submitting,
            )
            .having((s) => s.submitChunksDone, 'chunksDone', 1)
            .having((s) => s.submitChunksTotal, 'chunksTotal', 1),
        isA<BulkImportState>()
            .having(
              (s) => s.submitPhase,
              'phase',
              BulkImportSubmitPhase.success,
            )
            .having((s) => s.summary?.inserted, 'inserted', 1)
            .having((s) => s.summary?.total, 'total', 1),
      ],
      verify: (cubit) {
        verify(
          () => importRepository.upsertMcqBatch(
            any(
              that: isA<List<Map<String, dynamic>>>().having(
                (items) => items.single['chapter_id'],
                'chapter_id',
                101,
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<BulkImportCubit, BulkImportState>(
      'maps a 42501 rejection to a failure phase with a clear message',
      build: () {
        when(
          () => importRepository.upsertMcqBatch(any()),
        ).thenThrow(
          const ForbiddenFailure(
            'Server rejected the import (42501): editors cannot overwrite '
            'published or verified MCQs.',
          ),
        );
        return buildCubit();
      },
      seed: () => const BulkImportState(
        status: BulkImportStatus.ready,
        selectedLevelId: '1',
        selectedSubjectId: '53',
      ).copyWith(subjects: [_subject], chapters: [_chapter], rows: [validDraft()]),
      act: (cubit) => cubit.submitValidRows(),
      expect: () => [
        isA<BulkImportState>()
            .having(
              (s) => s.submitPhase,
              'phase',
              BulkImportSubmitPhase.submitting,
            ),
        isA<BulkImportState>()
            .having((s) => s.submitPhase, 'phase', BulkImportSubmitPhase.failure)
            .having((s) => s.errorMessage, 'message', contains('42501'))
            .having((s) => s.errorStatusCode, 'statusCode', 403),
      ],
    );

    blocTest<BulkImportCubit, BulkImportState>(
      'refuses to submit without a selected subject',
      build: () => buildCubit(),
      seed: () => const BulkImportState(
        status: BulkImportStatus.ready,
      ).copyWith(subjects: [_subject], chapters: [_chapter], rows: [validDraft()]),
      act: (cubit) => cubit.submitValidRows(),
      verify: (cubit) {
        expect(cubit.state.errorMessage, contains('subject'));
        verifyNever(() => importRepository.upsertMcqBatch(any()));
      },
    );
  });
}
