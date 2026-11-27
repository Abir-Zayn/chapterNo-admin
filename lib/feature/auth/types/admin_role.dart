// Pure-Dart enum representing ChapterNo admin authorization roles.
// Maps server-side public.admin_users role values to human-readable labels.

enum AdminRole {
  superAdmin('super_admin', 'Super Admin'),
  editor('editor', 'Editor'),
  reviewer('reviewer', 'Reviewer');

  const AdminRole(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static AdminRole fromDbValue(String? value) {
    return AdminRole.values.firstWhere(
      (role) => role.dbValue == value,
      orElse: () => AdminRole.editor,
    );
  }
}
