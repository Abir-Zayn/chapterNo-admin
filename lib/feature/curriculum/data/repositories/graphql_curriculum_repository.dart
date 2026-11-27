// GraphQL implementation of CurriculumRepository backed by Supabase pg_graphql.
// Enforces affectedCount checks and maps collection edges to domain entities.
import 'imports/graphql_curriculum_repository_imports.dart';

final class GraphQLCurriculumRepository implements CurriculumRepository {
  GraphQLCurriculumRepository(this._graphql);

  final GraphQLService _graphql;

  @override
  Future<CurriculumRoot> fetchRoot() async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.getCurriculumRoot,
      operationName: 'GetCurriculumRoot',
    );
    return CurriculumRoot(
      levels: CurriculumGraphQLHelpers.parseEdges(
        data['educationLevelsCollection'],
        EducationLevel.fromGraphQL,
      ),
      boards: CurriculumGraphQLHelpers.parseEdges(
        data['boardsCollection'],
        Board.fromGraphQL,
      ),
    );
  }

  @override
  Future<List<Subject>> fetchSubjects({
    required String levelId,
    bool? isActive,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.getSubjects,
      operationName: 'GetSubjects',
      variables: {'levelId': levelId, 'isActive': ?isActive},
    );
    return CurriculumGraphQLHelpers.parseEdges(
      data['subjectsCollection'],
      Subject.fromGraphQL,
    );
  }

  @override
  Future<List<Chapter>> fetchChaptersWithTopics({
    required String subjectId,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.getChaptersBySubject,
      operationName: 'GetChaptersBySubject',
      variables: {'subjectId': subjectId},
    );
    return CurriculumGraphQLHelpers.parseEdges(
      data['chaptersCollection'],
      Chapter.fromGraphQL,
    );
  }

  @override
  Future<EducationLevel> createEducationLevel({
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.createEducationLevel,
      operationName: 'CreateEducationLevel',
      variables: {
        'input': {
          'code': code.trim(),
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'displayOrder': displayOrder,
          'isActive': true,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['insertIntoEducationLevelsCollection'],
      EducationLevel.fromGraphQL,
    );
  }

  @override
  Future<EducationLevel> updateEducationLevel({
    required String id,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateEducationLevel,
      operationName: 'UpdateEducationLevel',
      variables: {
        'id': id,
        'patch': {
          'code': code.trim(),
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'displayOrder': displayOrder,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['updateEducationLevelsCollection'],
      EducationLevel.fromGraphQL,
    );
  }

  @override
  Future<void> setEducationLevelArchiveState({
    required String id,
    required bool isActive,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateEducationLevel,
      operationName: 'UpdateEducationLevel',
      variables: {
        'id': id,
        'patch': CurriculumGraphQLHelpers.archivePatch(isActive),
      },
    );
    CurriculumGraphQLHelpers.assertAffected(
      data['updateEducationLevelsCollection'],
    );
  }

  @override
  Future<Board> createBoard({
    required String educationLevelId,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.createBoard,
      operationName: 'CreateBoard',
      variables: {
        'input': {
          'educationLevelId': educationLevelId,
          'code': code.trim(),
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'displayOrder': displayOrder,
          'isActive': true,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['insertIntoBoardsCollection'],
      Board.fromGraphQL,
    );
  }

  @override
  Future<Board> updateBoard({
    required String id,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateBoard,
      operationName: 'UpdateBoard',
      variables: {
        'id': id,
        'patch': {
          'code': code.trim(),
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'displayOrder': displayOrder,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['updateBoardsCollection'],
      Board.fromGraphQL,
    );
  }

  @override
  Future<void> setBoardArchiveState({
    required String id,
    required bool isActive,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateBoard,
      operationName: 'UpdateBoard',
      variables: {
        'id': id,
        'patch': CurriculumGraphQLHelpers.archivePatch(isActive),
      },
    );
    CurriculumGraphQLHelpers.assertAffected(data['updateBoardsCollection']);
  }

  @override
  Future<Subject> createSubject({
    required String educationLevelId,
    required String code,
    required AcademicGroup academicGroup,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? nctbCode,
    String? shortNameBn,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.createSubject,
      operationName: 'CreateSubject',
      variables: {
        'input': {
          'educationLevelId': educationLevelId,
          'code': code.trim(),
          'nctbCode': CurriculumGraphQLHelpers.nullableTrim(nctbCode),
          'academicGroup': academicGroup.dbValue,
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'shortNameBn': CurriculumGraphQLHelpers.nullableTrim(shortNameBn),
          'displayOrder': displayOrder,
          'isActive': true,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['insertIntoSubjectsCollection'],
      Subject.fromGraphQL,
    );
  }

  @override
  Future<Subject> updateSubject({
    required String id,
    required String code,
    required AcademicGroup academicGroup,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? nctbCode,
    String? shortNameBn,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateSubject,
      operationName: 'UpdateSubject',
      variables: {
        'id': id,
        'patch': {
          'code': code.trim(),
          'nctbCode': CurriculumGraphQLHelpers.nullableTrim(nctbCode),
          'academicGroup': academicGroup.dbValue,
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'shortNameBn': CurriculumGraphQLHelpers.nullableTrim(shortNameBn),
          'displayOrder': displayOrder,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['updateSubjectsCollection'],
      Subject.fromGraphQL,
    );
  }

  @override
  Future<void> setSubjectArchiveState({
    required String id,
    required bool isActive,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateSubject,
      operationName: 'UpdateSubject',
      variables: {
        'id': id,
        'patch': CurriculumGraphQLHelpers.archivePatch(isActive),
      },
    );
    CurriculumGraphQLHelpers.assertAffected(data['updateSubjectsCollection']);
  }

  @override
  Future<Chapter> createChapter({
    required String subjectId,
    required int chapterNumber,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? descriptionBn,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.createChapter,
      operationName: 'CreateChapter',
      variables: {
        'input': {
          'subjectId': subjectId,
          'chapterNumber': chapterNumber,
          'code': code.trim(),
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'descriptionBn': CurriculumGraphQLHelpers.nullableTrim(descriptionBn),
          'displayOrder': displayOrder,
          'isActive': true,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['insertIntoChaptersCollection'],
      Chapter.fromGraphQL,
    );
  }

  @override
  Future<Chapter> updateChapter({
    required String id,
    required int chapterNumber,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? descriptionBn,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateChapter,
      operationName: 'UpdateChapter',
      variables: {
        'id': id,
        'patch': {
          'chapterNumber': chapterNumber,
          'code': code.trim(),
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'descriptionBn': CurriculumGraphQLHelpers.nullableTrim(descriptionBn),
          'displayOrder': displayOrder,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['updateChaptersCollection'],
      Chapter.fromGraphQL,
    );
  }

  @override
  Future<void> setChapterArchiveState({
    required String id,
    required bool isActive,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateChapter,
      operationName: 'UpdateChapter',
      variables: {
        'id': id,
        'patch': CurriculumGraphQLHelpers.archivePatch(isActive),
      },
    );
    CurriculumGraphQLHelpers.assertAffected(data['updateChaptersCollection']);
  }

  @override
  Future<Topic> createTopic({
    required String chapterId,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? summaryBn,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.createTopic,
      operationName: 'CreateTopic',
      variables: {
        'input': {
          'chapterId': chapterId,
          'code': code.trim(),
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'summaryBn': CurriculumGraphQLHelpers.nullableTrim(summaryBn),
          'displayOrder': displayOrder,
          'isActive': true,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['insertIntoTopicsCollection'],
      Topic.fromGraphQL,
    );
  }

  @override
  Future<Topic> updateTopic({
    required String id,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? summaryBn,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateTopic,
      operationName: 'UpdateTopic',
      variables: {
        'id': id,
        'patch': {
          'code': code.trim(),
          'nameBn': nameBn.trim(),
          'nameEn': nameEn.trim(),
          'summaryBn': CurriculumGraphQLHelpers.nullableTrim(summaryBn),
          'displayOrder': displayOrder,
        },
      },
    );
    return CurriculumGraphQLHelpers.parseFirstRecord(
      data['updateTopicsCollection'],
      Topic.fromGraphQL,
    );
  }

  @override
  Future<void> setTopicArchiveState({
    required String id,
    required bool isActive,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.updateTopic,
      operationName: 'UpdateTopic',
      variables: {
        'id': id,
        'patch': CurriculumGraphQLHelpers.archivePatch(isActive),
      },
    );
    CurriculumGraphQLHelpers.assertAffected(data['updateTopicsCollection']);
  }

  @override
  Future<void> deleteTopic(String id) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.deleteTopic,
      operationName: 'DeleteTopic',
      variables: {'id': id},
    );
    CurriculumGraphQLHelpers.assertAffected(data['deleteFromTopicsCollection']);
  }

  @override
  Future<int> reorderNodes({
    required String entity,
    required String parentId,
    required List<String> orderedIds,
  }) async {
    final data = await _graphql.execute(
      document: CurriculumGraphQLDocuments.reorderCurriculumNodes,
      operationName: 'ReorderCurriculumNodes',
      variables: {
        'entity': entity,
        'parentId': parentId,
        'orderedIds': orderedIds,
      },
    );
    return (data['reorderCurriculumNodes'] as num?)?.toInt() ?? 0;
  }
}
