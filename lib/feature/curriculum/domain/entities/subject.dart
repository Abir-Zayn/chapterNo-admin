// Pure-Dart domain entity for a curriculum Subject (e.g., পদার্থবিজ্ঞান).
// Maps pg_graphql subjectsCollection nodes with bilingual labels and group.
import 'curriculum_entity_imports.dart';

class Subject extends Equatable {
  const Subject({
    required this.id,
    required this.educationLevelId,
    required this.code,
    required this.academicGroup,
    required this.nameBn,
    required this.nameEn,
    required this.displayOrder,
    required this.isActive,
    this.nctbCode,
    this.shortNameBn,
    this.archivedAt,
    this.updatedAt,
  });

  final String id;
  final String educationLevelId;
  final String code;
  final String? nctbCode;
  final AcademicGroup academicGroup;
  final String nameBn;
  final String nameEn;
  final String? shortNameBn;
  final int displayOrder;
  final bool isActive;
  final DateTime? archivedAt;
  final DateTime? updatedAt;

  bool get isArchived => !isActive || archivedAt != null;

  factory Subject.fromGraphQL(Map<String, dynamic> map) {
    return Subject(
      id: (map['id'] ?? '').toString(),
      educationLevelId: (map['educationLevelId'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      nctbCode: map['nctbCode']?.toString(),
      academicGroup: AcademicGroup.fromDbValue(
        map['academicGroup']?.toString(),
      ),
      nameBn: (map['nameBn'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
      shortNameBn: map['shortNameBn']?.toString(),
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] != false,
      archivedAt: map['archivedAt'] == null
          ? null
          : DateTime.tryParse(map['archivedAt'].toString()),
      updatedAt: map['updatedAt'] == null
          ? null
          : DateTime.tryParse(map['updatedAt'].toString()),
    );
  }

  @override
  List<Object?> get props => [
    id,
    educationLevelId,
    code,
    nctbCode,
    academicGroup,
    nameBn,
    nameEn,
    shortNameBn,
    displayOrder,
    isActive,
    archivedAt,
    updatedAt,
  ];
}
