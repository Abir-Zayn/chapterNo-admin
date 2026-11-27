// Navigation destination model and canonical sidebar item definitions.
// Keeps AdminShell concise and centralizes top-level workspace routes.
import 'imports/admin_nav_item_imports.dart';

class AdminNavItem {
  const AdminNavItem({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
}

const List<AdminNavItem> kAdminNavItems = [
  AdminNavItem(
    label: 'Curriculum',
    path: '/curriculum',
    icon: FPhosphorIcons.books,
  ),
  AdminNavItem(
    label: 'MCQ Studio',
    path: '/mcq-studio',
    icon: FPhosphorIcons.pencilSimpleLine,
  ),
  AdminNavItem(
    label: 'Bulk Import',
    path: '/bulk-import',
    icon: FPhosphorIcons.fileCsv,
  ),
  AdminNavItem(
    label: 'Question Bank',
    path: '/question-bank',
    icon: FPhosphorIcons.database,
  ),
  AdminNavItem(
    label: 'Settings',
    path: '/settings',
    icon: FPhosphorIcons.gearSix,
  ),
];
