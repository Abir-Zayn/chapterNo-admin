// Central GraphQL query and mutation documents for Supabase pg_graphql.
// Matches camelCase collection and RPC names from 0002_curriculum_catalogue.

abstract final class CurriculumGraphQLDocuments {
  static const String getCurriculumRoot = r'''
query GetCurriculumRoot {
  educationLevelsCollection(
    orderBy: [{ displayOrder: AscNullsLast }]
  ) {
    edges {
      node {
        id
        code
        nameBn
        nameEn
        displayOrder
        isActive
        archivedAt
      }
    }
  }
  boardsCollection(
    orderBy: [{ displayOrder: AscNullsLast }]
  ) {
    edges {
      node {
        id
        educationLevelId
        code
        nameBn
        nameEn
        displayOrder
        isActive
        archivedAt
      }
    }
  }
}
''';

  static const String getSubjects = r'''
query GetSubjects($levelId: UUID!, $isActive: Boolean) {
  subjectsCollection(
    filter: {
      educationLevelId: { eq: $levelId }
      isActive: { eq: $isActive }
    }
    orderBy: [{ displayOrder: AscNullsLast }, { nameBn: AscNullsLast }]
  ) {
    edges {
      node {
        id
        educationLevelId
        code
        nctbCode
        academicGroup
        nameBn
        nameEn
        shortNameBn
        displayOrder
        isActive
        archivedAt
        updatedAt
      }
    }
  }
}
''';

  static const String getChaptersBySubject = r'''
query GetChaptersBySubject($subjectId: UUID!) {
  chaptersCollection(
    filter: { subjectId: { eq: $subjectId } }
    orderBy: [{ displayOrder: AscNullsLast }, { chapterNumber: AscNullsLast }]
  ) {
    edges {
      node {
        id
        subjectId
        chapterNumber
        code
        nameBn
        nameEn
        descriptionBn
        displayOrder
        isActive
        archivedAt
        topicsCollection(orderBy: [{ displayOrder: AscNullsLast }]) {
          edges {
            node {
              id
              chapterId
              code
              nameBn
              nameEn
              summaryBn
              displayOrder
              isActive
              archivedAt
            }
          }
        }
      }
    }
  }
}
''';

  static const String createEducationLevel = r'''
mutation CreateEducationLevel($input: EducationLevelsInsertInput!) {
  insertIntoEducationLevelsCollection(objects: [$input]) {
    affectedCount
    records {
      id
      code
      nameBn
      nameEn
      displayOrder
      isActive
      archivedAt
    }
  }
}
''';

  static const String updateEducationLevel = r'''
mutation UpdateEducationLevel($id: UUID!, $patch: EducationLevelsUpdateInput!) {
  updateEducationLevelsCollection(
    filter: { id: { eq: $id } }
    set: $patch
    atMost: 1
  ) {
    affectedCount
    records {
      id
      code
      nameBn
      nameEn
      displayOrder
      isActive
      archivedAt
    }
  }
}
''';

  static const String createBoard = r'''
mutation CreateBoard($input: BoardsInsertInput!) {
  insertIntoBoardsCollection(objects: [$input]) {
    affectedCount
    records {
      id
      educationLevelId
      code
      nameBn
      nameEn
      displayOrder
      isActive
      archivedAt
    }
  }
}
''';

  static const String updateBoard = r'''
mutation UpdateBoard($id: UUID!, $patch: BoardsUpdateInput!) {
  updateBoardsCollection(
    filter: { id: { eq: $id } }
    set: $patch
    atMost: 1
  ) {
    affectedCount
    records {
      id
      educationLevelId
      code
      nameBn
      nameEn
      displayOrder
      isActive
      archivedAt
    }
  }
}
''';

  static const String createSubject = r'''
mutation CreateSubject($input: SubjectsInsertInput!) {
  insertIntoSubjectsCollection(objects: [$input]) {
    affectedCount
    records {
      id
      educationLevelId
      code
      nctbCode
      academicGroup
      nameBn
      nameEn
      shortNameBn
      displayOrder
      isActive
      archivedAt
      updatedAt
    }
  }
}
''';

  static const String updateSubject = r'''
mutation UpdateSubject($id: UUID!, $patch: SubjectsUpdateInput!) {
  updateSubjectsCollection(
    filter: { id: { eq: $id } }
    set: $patch
    atMost: 1
  ) {
    affectedCount
    records {
      id
      educationLevelId
      code
      nctbCode
      academicGroup
      nameBn
      nameEn
      shortNameBn
      displayOrder
      isActive
      archivedAt
      updatedAt
    }
  }
}
''';

  static const String createChapter = r'''
mutation CreateChapter($input: ChaptersInsertInput!) {
  insertIntoChaptersCollection(objects: [$input]) {
    affectedCount
    records {
      id
      subjectId
      chapterNumber
      code
      nameBn
      nameEn
      descriptionBn
      displayOrder
      isActive
      archivedAt
    }
  }
}
''';

  static const String updateChapter = r'''
mutation UpdateChapter($id: UUID!, $patch: ChaptersUpdateInput!) {
  updateChaptersCollection(
    filter: { id: { eq: $id } }
    set: $patch
    atMost: 1
  ) {
    affectedCount
    records {
      id
      subjectId
      chapterNumber
      code
      nameBn
      nameEn
      descriptionBn
      displayOrder
      isActive
      archivedAt
    }
  }
}
''';

  static const String createTopic = r'''
mutation CreateTopic($input: TopicsInsertInput!) {
  insertIntoTopicsCollection(objects: [$input]) {
    affectedCount
    records {
      id
      chapterId
      code
      nameBn
      nameEn
      summaryBn
      displayOrder
      isActive
      archivedAt
    }
  }
}
''';

  static const String updateTopic = r'''
mutation UpdateTopic($id: UUID!, $patch: TopicsUpdateInput!) {
  updateTopicsCollection(
    filter: { id: { eq: $id } }
    set: $patch
    atMost: 1
  ) {
    affectedCount
    records {
      id
      chapterId
      code
      nameBn
      nameEn
      summaryBn
      displayOrder
      isActive
      archivedAt
    }
  }
}
''';

  static const String deleteTopic = r'''
mutation DeleteTopic($id: UUID!) {
  deleteFromTopicsCollection(filter: { id: { eq: $id } }, atMost: 1) {
    affectedCount
  }
}
''';

  static const String reorderCurriculumNodes = r'''
mutation ReorderCurriculumNodes(
  $entity: String!
  $parentId: UUID!
  $orderedIds: [UUID!]!
) {
  reorderCurriculumNodes(
    pEntity: $entity
    pParentId: $parentId
    pOrderedIds: $orderedIds
  )
}
''';
}
