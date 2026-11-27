// Navigation destination model and canonical sidebar item definitions.
// Keeps AdminShell concise and centralizes top-level workspace routes.
import 'imports/admin_nav_item_imports.dart';

class AdminNavItem {
  const AdminNavItem({
    required this.label,
    required this.path,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String path;
  final IconData icon;
  final IconData activeIcon;
}

const List<AdminNavItem> kAdminNavItems = [
  AdminNavItem(
    label: 'Curriculum',
    path: '/curriculum',
    icon: PhosphorIconsRegular.books,
    activeIcon: PhosphorIconsFill.books,
  ),
  AdminNavItem(
    label: 'MCQ Studio',
    path: '/mcq-studio',
    icon: PhosphorIconsRegular.pencilSimpleLine,
    activeIcon: PhosphorIconsFill.pencilSimpleLine,
  ),
  AdminNavItem(
    label: 'Bulk Import',
    path: '/bulk-import',
    icon: PhosphorIconsRegular.fileCsv,
    activeIcon: PhosphorIconsFill.fileCsv,
  ),
  AdminNavItem(
    label: 'Question Bank',
    path: '/question-bank',
    icon: PhosphorIconsRegular.database,
    activeIcon: PhosphorIconsFill.database,
  ),
  AdminNavItem(
    label: 'Settings',
    path: '/settings',
    icon: PhosphorIconsRegular.gearSix,
    activeIcon: PhosphorIconsFill.gearSix,
  ),
];
