// Clean minimal sidebar shell inspired by editorial manager dashboards.
// Supports collapsible Curriculum sub-navigation, theme toggle, and mobile drawer.
import 'imports/admin_shell_imports.dart';

class AdminShell extends StatefulWidget {
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
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final themeMode = _safeThemeMode(context);
    final isDark = themeMode == ThemeMode.dark;
    final activeItem = kAdminNavItems.firstWhere(
      (item) => widget.currentPath.startsWith(item.path),
      orElse: () => kAdminNavItems.first,
    );

    final sidebar = _SidebarPanel(
      currentPath: widget.currentPath,
      adminUser: widget.adminUser,
      onSignOut: widget.onSignOut,
      closeDrawerOnTap: !isDesktop,
      isDark: isDark,
      onToggleTheme: () => _safeThemeCubit(context)?.toggle(),
      onCollapse: isDesktop
          ? () => setState(() => _sidebarCollapsed = !_sidebarCollapsed)
          : null,
    );

    return Scaffold(
      backgroundColor: palette.canvas,
      drawer: isDesktop ? null : Drawer(width: 248, child: sidebar),
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
                  onPressed: () => _safeThemeCubit(context)?.toggle(),
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
            if (isDesktop && !_sidebarCollapsed)
              SizedBox(width: 248, child: sidebar),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDesktop && _sidebarCollapsed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        border: Border(
                          bottom: BorderSide(color: palette.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Expand sidebar',
                            onPressed: () =>
                                setState(() => _sidebarCollapsed = false),
                            icon: const Icon(
                              PhosphorIconsRegular.list,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ChapterNo Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: palette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 28 : 16),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarPanel extends StatefulWidget {
  const _SidebarPanel({
    required this.currentPath,
    required this.adminUser,
    required this.onSignOut,
    required this.closeDrawerOnTap,
    required this.isDark,
    required this.onToggleTheme,
    this.onCollapse,
  });

  final String currentPath;
  final AdminUser adminUser;
  final VoidCallback onSignOut;
  final bool closeDrawerOnTap;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback? onCollapse;

  @override
  State<_SidebarPanel> createState() => _SidebarPanelState();
}

class _SidebarPanelState extends State<_SidebarPanel> {
  bool _curriculumExpanded = true;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final curriculumCubit = _safeCurriculumCubit(context);
    final activeTab =
        curriculumCubit?.state.activeTab ?? CurriculumTab.syllabus;
    final initials = widget.adminUser.displayName.trim().isNotEmpty
        ? widget.adminUser.displayName.trim()[0].toUpperCase()
        : 'A';

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(right: BorderSide(color: palette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 10, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ChapterNo Admin',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                if (widget.onCollapse != null)
                  IconButton(
                    tooltip: 'Collapse sidebar',
                    onPressed: widget.onCollapse,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      PhosphorIconsRegular.list,
                      size: 18,
                      color: palette.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              children: [
                for (final item in kAdminNavItems) ...[
                  if (item.path == '/curriculum') ...[
                    _NavTile(
                      item: item,
                      isSelected: widget.currentPath.startsWith(item.path),
                      trailing: Icon(
                        _curriculumExpanded
                            ? PhosphorIconsRegular.caretUp
                            : PhosphorIconsRegular.caretDown,
                        size: 14,
                        color: palette.textSecondary,
                      ),
                      onTap: () {
                        setState(
                          () => _curriculumExpanded = !_curriculumExpanded,
                        );
                        if (!widget.currentPath.startsWith('/curriculum')) {
                          if (widget.closeDrawerOnTap) {
                            Navigator.of(context).pop();
                          }
                          context.go('/curriculum');
                        }
                      },
                    ),
                    if (_curriculumExpanded) ...[
                      const SizedBox(height: 2),
                      _SubNavTile(
                        label: 'Subjects & Syllabus',
                        isSelected:
                            widget.currentPath.startsWith('/curriculum') &&
                            activeTab == CurriculumTab.syllabus,
                        onTap: () {
                          curriculumCubit?.setTab(CurriculumTab.syllabus);
                          if (widget.closeDrawerOnTap) {
                            Navigator.of(context).pop();
                          }
                          if (!widget.currentPath.startsWith('/curriculum')) {
                            context.go('/curriculum');
                          }
                        },
                      ),
                      _SubNavTile(
                        label: 'Boards & Levels',
                        isSelected:
                            widget.currentPath.startsWith('/curriculum') &&
                            activeTab == CurriculumTab.boardsAndLevels,
                        onTap: () {
                          curriculumCubit?.setTab(
                            CurriculumTab.boardsAndLevels,
                          );
                          if (widget.closeDrawerOnTap) {
                            Navigator.of(context).pop();
                          }
                          if (!widget.currentPath.startsWith('/curriculum')) {
                            context.go('/curriculum');
                          }
                        },
                      ),
                    ],
                  ] else
                    _NavTile(
                      item: item,
                      isSelected: widget.currentPath.startsWith(item.path),
                      onTap: () {
                        if (widget.closeDrawerOnTap) {
                          Navigator.of(context).pop();
                        }
                        context.go(item.path);
                      },
                    ),
                  const SizedBox(height: 2),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Workspace',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _WorkspaceChannelTile(
                  icon: PhosphorIconsRegular.sun,
                  activeIcon: PhosphorIconsRegular.moon,
                  isDark: widget.isDark,
                  title: widget.isDark ? 'Dark Theme' : 'Light Theme',
                  subtitle: 'Switch appearance',
                  onTap: widget.onToggleTheme,
                ),
                _WorkspaceChannelTile(
                  icon: PhosphorIconsRegular.shieldCheck,
                  activeIcon: PhosphorIconsRegular.shieldCheck,
                  isDark: false,
                  title: widget.adminUser.role.label,
                  subtitle: 'Verified Postgres RLS',
                  onTap: () {
                    if (widget.closeDrawerOnTap) Navigator.of(context).pop();
                    context.go('/settings');
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: palette.primaryTint,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.adminUser.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: palette.textPrimary,
                        ),
                      ),
                      Text(
                        widget.adminUser.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Sign Out',
                  onPressed: widget.onSignOut,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    PhosphorIconsRegular.signOut,
                    size: 17,
                    color: palette.textSecondary,
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
    this.trailing,
  });

  final AdminNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 18,
                color: isSelected ? palette.textPrimary : palette.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SubNavTile extends StatelessWidget {
  const _SubNavTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Material(
      color: isSelected ? palette.primaryTint : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 10, 8),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? palette.textPrimary : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

ThemeMode _safeThemeMode(BuildContext context) {
  try {
    return context.watch<ThemeCubit>().state;
  } catch (_) {
    return ThemeMode.light;
  }
}

ThemeCubit? _safeThemeCubit(BuildContext context) {
  try {
    return context.read<ThemeCubit>();
  } catch (_) {
    return null;
  }
}

CurriculumCubit? _safeCurriculumCubit(BuildContext context) {
  try {
    return context.watch<CurriculumCubit>();
  } catch (_) {
    return null;
  }
}

class _WorkspaceChannelTile extends StatelessWidget {
  const _WorkspaceChannelTile({
    required this.icon,
    required this.activeIcon,
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isDark;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: palette.primaryTint,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.border),
              ),
              child: Icon(
                isDark ? activeIcon : icon,
                size: 14,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: palette.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
