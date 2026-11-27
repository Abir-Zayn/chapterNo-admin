// Pure-Dart domain entity for a Bangladesh Education Board (e.g., Dhaka).
// Maps pg_graphql boardsCollection nodes without Flutter imports.
import 'imports/curriculum_entity_imports.dart';

class Board extends Equatable {
  const Board({
    required this.id,
    required this.educationLevelId,
    required this.code,
    required this.nameBn,
    required this.nameEn,
    required this.displayOrder,
    required this.isActive,
    this.archivedAt,
  });

  final String id;
  final String educationLevelId;
  final String code;
  final String nameBn;
  final String nameEn;
  final int displayOrder;
  final bool isActive;
  final DateTime? archivedAt;

  bool get isArchived => !isActive || archivedAt != null;

  factory Board.fromGraphQL(Map<String, dynamic> map) {
    return Board(
      id: (map['id'] ?? '').toString(),
      educationLevelId: (map['educationLevelId'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
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
    educationLevelId,
    code,
    nameBn,
    nameEn,
    displayOrder,
    isActive,
    archivedAt,
  ];
}
