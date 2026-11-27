// Pure-Dart domain entity for a granular Topic under a Chapter.
// Maps pg_graphql topicsCollection nodes without Flutter imports.
import 'imports/curriculum_entity_imports.dart';

class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.chapterId,
    required this.code,
    required this.nameBn,
    required this.nameEn,
    required this.displayOrder,
    required this.isActive,
    this.summaryBn,
    this.archivedAt,
  });

  final String id;
  final String chapterId;
  final String code;
  final String nameBn;
  final String nameEn;
  final String? summaryBn;
  final int displayOrder;
  final bool isActive;
  final DateTime? archivedAt;

  bool get isArchived => !isActive || archivedAt != null;

  factory Topic.fromGraphQL(Map<String, dynamic> map) {
    return Topic(
      id: (map['id'] ?? '').toString(),
      chapterId: (map['chapterId'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
      summaryBn: map['summaryBn']?.toString(),
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] != false,
      archivedAt: map['archivedAt'] == null
          ? null
          : DateTime.tryParse(map['archivedAt'].toString()),
    );
  }

  @override
  List<Object?> get props => [
    id,
    chapterId,
    code,
    nameBn,
    nameEn,
    summaryBn,
    displayOrder,
    isActive,
    archivedAt,
  ];
}
