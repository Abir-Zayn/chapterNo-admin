// Abstract repository contract for Curriculum Catalogue reads and writes.
// Keeps domain and Cubit layers decoupled from pg_graphql implementation details.
import 'curriculum_repository_imports.dart';

abstract interface class CurriculumRepository {
  Future<CurriculumRoot> fetchRoot();

  Future<List<Subject>> fetchSubjects({
    required String levelId,
    bool? isActive,
  });

  Future<List<Chapter>> fetchChaptersWithTopics({required String subjectId});

  Future<EducationLevel> createEducationLevel({
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  });

  Future<EducationLevel> updateEducationLevel({
    required String id,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  });

  Future<void> setEducationLevelArchiveState({
    required String id,
    required bool isActive,
  });

  Future<Board> createBoard({
    required String educationLevelId,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  });

  Future<Board> updateBoard({
    required String id,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  });

  Future<void> setBoardArchiveState({
    required String id,
    required bool isActive,
  });

  Future<Subject> createSubject({
    required String educationLevelId,
    required String code,
    required AcademicGroup academicGroup,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? nctbCode,
    String? shortNameBn,
  });

  Future<Subject> updateSubject({
    required String id,
    required String code,
    required AcademicGroup academicGroup,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? nctbCode,
    String? shortNameBn,
  });

  Future<void> setSubjectArchiveState({
    required String id,
    required bool isActive,
  });

  Future<Chapter> createChapter({
    required String subjectId,
    required int chapterNumber,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? descriptionBn,
  });

  Future<Chapter> updateChapter({
    required String id,
    required int chapterNumber,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? descriptionBn,
  });

  Future<void> setChapterArchiveState({
    required String id,
    required bool isActive,
  });

  Future<Topic> createTopic({
    required String chapterId,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? summaryBn,
  });

  Future<Topic> updateTopic({
    required String id,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? summaryBn,
  });

  Future<void> setTopicArchiveState({
    required String id,
    required bool isActive,
  });

  Future<void> deleteTopic(String id);

  Future<int> reorderNodes({
    required String entity,
    required String parentId,
    required List<String> orderedIds,
  });
}
