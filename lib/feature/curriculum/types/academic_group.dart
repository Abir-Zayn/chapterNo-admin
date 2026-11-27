// Pure-Dart enum for NCTB academic groups in the Curriculum Catalogue.
// Maps Postgres academic_group values to Bangla and English labels.

enum AcademicGroup {
  common('common', 'সাধারণ', 'Common'),
  science('science', 'বিজ্ঞান', 'Science'),
  businessStudies('business_studies', 'ব্যবসায় শিক্ষা', 'Business Studies'),
  humanities('humanities', 'মানবিক', 'Humanities');

  const AcademicGroup(this.dbValue, this.labelBn, this.labelEn);

  final String dbValue;
  final String labelBn;
  final String labelEn;

  static AcademicGroup fromDbValue(String? value) {
    return AcademicGroup.values.firstWhere(
      (group) => group.dbValue == value,
      orElse: () => AcademicGroup.common,
    );
  }
}
