// Pure-Dart domain entity representing an authorized ChapterNo admin.
// Maps server-side public.admin_users rows without Flutter or Supabase imports.
import 'admin_user_imports.dart';

class AdminUser extends Equatable {
  const AdminUser({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isActive,
  });

  final String userId;
  final String email;
  final String displayName;
  final AdminRole role;
  final bool isActive;

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      userId: (map['user_id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      displayName: (map['display_name'] ?? '').toString(),
      role: AdminRole.fromDbValue(map['role']?.toString()),
      isActive: map['is_active'] == true,
    );
  }

  @override
  List<Object?> get props => [userId, email, displayName, role, isActive];
}
