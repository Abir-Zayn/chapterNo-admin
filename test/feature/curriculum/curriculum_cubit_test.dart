// Unit tests for CurriculumCubit cascading load, creation, and reorder.
// Verifies optimistic chapter reorder and rollback on GraphQL failure.
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/board.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/chapter.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/curriculum_root.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/education_level.dart';
import 'package:chapterno_admin/feature/curriculum/domain/entities/subject.dart';
import 'package:chapterno_admin/feature/curriculum/domain/repositories/curriculum_repository.dart';
import 'package:chapterno_admin/feature/curriculum/screens/bloc/curriculum_cubit.dart';
import 'package:chapterno_admin/feature/curriculum/screens/bloc/curriculum_state.dart';
import 'package:chapterno_admin/feature/curriculum/types/academic_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCurriculumRepository extends Mock implements CurriculumRepository {}

void main() {
  late _MockCurriculumRepository repository;

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
  const ch1 = Chapter(
    id: 'ch-1',
    subjectId: 'sub-1',
    chapterNumber: 1,
    code: 'ssc_phy_ch01',
    nameBn: 'ভৌত রাশি ও পরিমাপ',
    nameEn: 'Physical Quantities',
    displayOrder: 1,
    isActive: true,
  );
  const ch2 = Chapter(
    id: 'ch-2',
    subjectId: 'sub-1',
    chapterNumber: 2,
    code: 'ssc_phy_ch02',
    nameBn: 'গতি',
    nameEn: 'Motion',
    displayOrder: 2,
    isActive: true,
  );

  setUp(() {
    repository = _MockCurriculumRepository();
  });

  test('loadInitial cascades Level -> Subject -> Chapters', () async {
    when(() => repository.fetchRoot()).thenAnswer(
      (_) async => const CurriculumRoot(levels: [ssc], boards: [dhaka]),
    );
    when(() => repository.fetchSubjects(levelId: 'lvl-1', isActive: true))
        .thenAnswer((_) async => const [physics]);
    when(() => repository.fetchChaptersWithTopics(subjectId: 'sub-1'))
        .thenAnswer((_) async => const [ch1, ch2]);

    final cubit = CurriculumCubit(repository);
    await cubit.loadInitial();

    expect(cubit.state.status, CurriculumStatus.ready);
    expect(cubit.state.selectedLevelId, 'lvl-1');
    expect(cubit.state.selectedSubjectId, 'sub-1');
    expect(cubit.state.selectedChapterId, 'ch-1');
    expect(cubit.state.chapters.length, 2);
  });

  test(
    'reorderChapters reverts state and sets errorMessage on failure',
    () async {
      when(() => repository.fetchRoot()).thenAnswer(
        (_) async => const CurriculumRoot(levels: [ssc], boards: [dhaka]),
      );
      when(() => repository.fetchSubjects(levelId: 'lvl-1', isActive: true))
          .thenAnswer((_) async => const [physics]);
      when(() => repository.fetchChaptersWithTopics(subjectId: 'sub-1'))
          .thenAnswer((_) async => const [ch1, ch2]);
      when(
        () => repository.reorderNodes(
          entity: 'chapter',
          parentId: 'sub-1',
          orderedIds: ['ch-2', 'ch-1'],
        ),
      ).thenThrow(const ForbiddenFailure('Permission denied.'));

      final cubit = CurriculumCubit(repository);
      await cubit.loadInitial();
      await cubit.reorderChapters(0, 1);

      expect(cubit.state.chapters.map((c) => c.id).toList(), ['ch-1', 'ch-2']);
      expect(cubit.state.errorMessage, 'Permission denied.');
    },
  );
}
