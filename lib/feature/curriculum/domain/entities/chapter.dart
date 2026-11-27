// Pure-Dart domain entity for a textbook Chapter and its nested Topics.
// Maps pg_graphql chaptersCollection nodes without Flutter imports.
import 'imports/curriculum_entity_imports.dart';
import 'topic.dart';

class Chapter extends Equatable {
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.chapterNumber,
    required this.code,
    required this.nameBn,
    required this.nameEn,
    required this.displayOrder,
    required this.isActive,
    this.descriptionBn,
    this.archivedAt,
    this.topics = const [],
  });

  final String id;
  final String subjectId;
  final int chapterNumber;
  final String code;
  final String nameBn;
  final String nameEn;
  final String? descriptionBn;
  final int displayOrder;
  final bool isActive;
  final DateTime? archivedAt;
  final List<Topic> topics;

  bool get isArchived => !isActive || archivedAt != null;

  factory Chapter.fromGraphQL(Map<String, dynamic> map) {
    final rawTopics = map['topicsCollection'];
    final topicList = <Topic>[];
    if (rawTopics is Map && rawTopics['edges'] is List) {
      for (final edge in rawTopics['edges'] as List) {
        if (edge is Map && edge['node'] is Map) {
          topicList.add(
            Topic.fromGraphQL(Map<String, dynamic>.from(edge['node'] as Map)),
          );
        }
      }
    }

    return Chapter(
      id: (map['id'] ?? '').toString(),
      subjectId: (map['subjectId'] ?? '').toString(),
      chapterNumber: (map['chapterNumber'] as num?)?.toInt() ?? 1,
      code: (map['code'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
      descriptionBn: map['descriptionBn']?.toString(),
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] != false,
      archivedAt: map['archivedAt'] == null
          ? null
          : DateTime.tryParse(map['archivedAt'].toString()),
      topics: topicList,
    );
  }

  @override
  List<Object?> get props => [
    id,
    subjectId,
    chapterNumber,
    code,
    nameBn,
    nameEn,
    descriptionBn,
    displayOrder,
    isActive,
    archivedAt,
    topics,
  ];
}
