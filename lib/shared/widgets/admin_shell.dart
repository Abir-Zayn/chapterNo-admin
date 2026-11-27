// Responsive desktop sidebar shell with SelectionArea and solid 1dp dividers.
// Hosts navigation, theme mode toggle, verified admin badge, and sign-out.
import 'imports/admin_shell_imports.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.currentPath,
    required this.adminUser,
    required this.onSignOut,
    required this.child,
  });

  final String currentPath;
  final AdminUser adminUser;
  final VoidCallback onSignOut;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final themeMode = context.watch<ThemeCubit?>()?.state ?? ThemeMode.light;
    final isDark = themeMode == ThemeMode.dark;
    final activeItem = kAdminNavItems.firstWhere(
      (item) => currentPath.startsWith(item.path),
      orElse: () => kAdminNavItems.first,
    );

    final sidebar = _SidebarPanel(
      currentPath: currentPath,
      adminUser: adminUser,
      onSignOut: onSignOut,
      closeDrawerOnTap: !isDesktop,
      isDark: isDark,
      onToggleTheme: () => context.read<ThemeCubit?>()?.toggle(),
    );

    return Scaffold(
      backgroundColor: palette.canvas,
      drawer: isDesktop ? null : Drawer(width: 256, child: sidebar),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: palette.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                activeItem.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: isDark
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                  onPressed: () => context.read<ThemeCubit?>()?.toggle(),
                  icon: Icon(
                    isDark
                        ? PhosphorIconsRegular.sun
                        : PhosphorIconsRegular.moon,
                    size: 18,
                  ),
                ),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1),
              ),
            ),
      body: SelectionArea(
        child: Row(
          children: [
            if (isDesktop) SizedBox(width: 256, child: sidebar),
            Expanded(
              child: Padding(padding: const EdgeInsets.all(24), child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarPanel extends StatelessWidget {
  const _SidebarPanel({
    required this.currentPath,
    required this.adminUser,
    required this.onSignOut,
    required this.closeDrawerOnTap,
    required this.isDark,
    required this.onToggleTheme,
  });

  final String currentPath;
  final AdminUser adminUser;
  final VoidCallback onSignOut;
  final bool closeDrawerOnTap;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(right: BorderSide(color: palette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    PhosphorIconsFill.graduationCap,
                    size: 18,
                    color: palette.onPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ChapterNo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: palette.textPrimary,
                        ),
                      ),
                      Text(
                        'Admin Workspace',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: kAdminNavItems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = kAdminNavItems[index];
                return _NavTile(
                  item: item,
                  isSelected: currentPath.startsWith(item.path),
                  onTap: () {
                    if (closeDrawerOnTap) Navigator.of(context).pop();
                    context.go(item.path);
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        adminUser.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusBadge.neutral(adminUser.role.label),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  adminUser.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onToggleTheme,
                    icon: Icon(
                      isDark
                          ? PhosphorIconsRegular.sun
                          : PhosphorIconsRegular.moon,
                      size: 16,
                    ),
                    label: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSignOut,
                    icon: const Icon(PhosphorIconsRegular.signOut, size: 16),
                    label: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AdminNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Material(
      color: isSelected ? palette.primaryTint : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? palette.primary.withValues(alpha: 0.25)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 18,
                color: isSelected ? palette.primary : palette.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? palette.primary : palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
