// Unit tests for GraphQLCurriculumRepository using a mocked GraphQLService.
// Verifies GraphQL variables, UTF-8 Bangla round-trip, and affectedCount checks.
import 'package:chapterno_admin/core/error/app_failure.dart';
import 'package:chapterno_admin/core/graphql/graphql_service.dart';
import 'package:chapterno_admin/feature/curriculum/data/repositories/graphql_curriculum_repository.dart';
import 'package:chapterno_admin/feature/curriculum/types/academic_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGraphQLService extends Mock implements GraphQLService {}

void main() {
  late _MockGraphQLService graphql;
  late GraphQLCurriculumRepository repository;

  setUp(() {
    graphql = _MockGraphQLService();
    repository = GraphQLCurriculumRepository(graphql);
  });

  test('fetchRoot parses levels and boards from GraphQL edges', () async {
    when(
      () => graphql.execute(
        document: any(named: 'document'),
        variables: any(named: 'variables'),
        operationName: 'GetCurriculumRoot',
      ),
    ).thenAnswer(
      (_) async => {
        'educationLevelsCollection': {
          'edges': [
            {
              'node': {
                'id': 'lvl-1',
                'code': 'ssc',
                'nameBn': 'এসএসসি',
                'nameEn': 'SSC',
                'displayOrder': 1,
                'isActive': true,
              },
            },
          ],
        },
        'boardsCollection': {
          'edges': [
            {
              'node': {
                'id': 'brd-1',
                'educationLevelId': 'lvl-1',
                'code': 'dhaka',
                'nameBn': 'ঢাকা',
                'nameEn': 'Dhaka',
                'displayOrder': 1,
                'isActive': true,
              },
            },
          ],
        },
      },
    );

    final root = await repository.fetchRoot();

    expect(root.levels.length, 1);
    expect(root.levels.first.nameBn, 'এসএসসি');
    expect(root.boards.length, 1);
    expect(root.boards.first.nameBn, 'ঢাকা');
  });

  test('createSubject sends UTF-8 Bangla payload and parses record', () async {
    when(
      () => graphql.execute(
        document: any(named: 'document'),
        variables: any(named: 'variables'),
        operationName: 'CreateSubject',
      ),
    ).thenAnswer(
      (_) async => {
        'insertIntoSubjectsCollection': {
          'affectedCount': 1,
          'records': [
            {
              'id': 'sub-1',
              'educationLevelId': 'lvl-1',
              'code': 'ssc_physics',
              'nctbCode': '136',
              'academicGroup': 'science',
              'nameBn': 'পদার্থবিজ্ঞান',
              'nameEn': 'Physics',
              'shortNameBn': 'পদার্থ',
              'displayOrder': 1,
              'isActive': true,
            },
          ],
        },
      },
    );

    final subject = await repository.createSubject(
      educationLevelId: 'lvl-1',
      code: 'ssc_physics',
      academicGroup: AcademicGroup.science,
      nameBn: 'পদার্থবিজ্ঞান',
      nameEn: 'Physics',
      displayOrder: 1,
      nctbCode: '136',
      shortNameBn: 'পদার্থ',
    );

    expect(subject.nameBn, 'পদার্থবিজ্ঞান');
    expect(subject.academicGroup, AcademicGroup.science);
  });

  test(
    'setSubjectArchiveState throws NotFoundFailure when affectedCount == 0',
    () async {
      when(
        () => graphql.execute(
          document: any(named: 'document'),
          variables: any(named: 'variables'),
          operationName: 'UpdateSubject',
        ),
      ).thenAnswer(
        (_) async => {
          'updateSubjectsCollection': {'affectedCount': 0, 'records': []},
        },
      );

      expect(
        () => repository.setSubjectArchiveState(id: 'missing', isActive: false),
        throwsA(isA<NotFoundFailure>()),
      );
    },
  );

  test('reorderNodes sends entity, parentId, and orderedIds', () async {
    when(
      () => graphql.execute(
        document: any(named: 'document'),
        variables: {
          'entity': 'chapter',
          'parentId': 'sub-1',
          'orderedIds': ['ch-2', 'ch-1'],
        },
        operationName: 'ReorderCurriculumNodes',
      ),
    ).thenAnswer((_) async => {'reorderCurriculumNodes': 2});

    final count = await repository.reorderNodes(
      entity: 'chapter',
      parentId: 'sub-1',
      orderedIds: ['ch-2', 'ch-1'],
    );

    expect(count, 2);
  });
}
