// Pure-Dart domain entity for a top-level Education Level (e.g., SSC).
// Maps pg_graphql educationLevelsCollection nodes without Flutter imports.
import 'curriculum_entity_imports.dart';

class EducationLevel extends Equatable {
  const EducationLevel({
    required this.id,
    required this.code,
    required this.nameBn,
    required this.nameEn,
    required this.displayOrder,
    required this.isActive,
    this.archivedAt,
  });

  final String id;
  final String code;
  final String nameBn;
  final String nameEn;
  final int displayOrder;
  final bool isActive;
  final DateTime? archivedAt;

  bool get isArchived => !isActive || archivedAt != null;

  factory EducationLevel.fromGraphQL(Map<String, dynamic> map) {
    return EducationLevel(
      id: (map['id'] ?? '').toString(),
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
    code,
    nameBn,
    nameEn,
    displayOrder,
    isActive,
    archivedAt,
  ];
}
