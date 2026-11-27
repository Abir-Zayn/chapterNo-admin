// Forui sidebar shell with Curriculum sub-navigation and mobile navigation.
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    final themeMode = _safeThemeMode(context);
    final isDark = themeMode == ThemeMode.dark;
    final curriculumCubit = _safeCurriculumCubit(context);
    final activeTab =
        curriculumCubit?.state.activeTab ?? CurriculumTab.syllabus;
    final activeIndex = kAdminNavItems.indexWhere(
      (item) => widget.currentPath.startsWith(item.path),
    );
    final activeItem = activeIndex < 0
        ? kAdminNavItems.first
        : kAdminNavItems[activeIndex];
    final initials = widget.adminUser.displayName.trim().isNotEmpty
        ? widget.adminUser.displayName.trim()[0].toUpperCase()
        : 'A';

    final sidebar = FSidebar(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 10, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'ChapterNo Admin',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.md.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
            ),
            Semantics(
              label: 'Collapse sidebar',
              button: true,
              child: FButton(
                variant: .ghost,
                size: .sm,
                mainAxisSize: MainAxisSize.min,
                onPress: () => setState(() => _sidebarCollapsed = true),
                child: const Icon(FPhosphorIcons.list, size: 18),
              ),
            ),
          ],
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.secondary,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: typography.body.sm.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
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
                    style: typography.body.sm.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                  Text(
                    widget.adminUser.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typography.body.xs.copyWith(
                      fontSize: 11,
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: 'Sign Out',
              button: true,
              child: FButton(
                variant: .ghost,
                size: .sm,
                mainAxisSize: MainAxisSize.min,
                onPress: widget.onSignOut,
                child: const Icon(FPhosphorIcons.signOut, size: 17),
              ),
            ),
          ],
        ),
      ),
      children: [
        FSidebarGroup(
          children: [
            for (final item in kAdminNavItems)
              if (item.path == '/curriculum')
                FSidebarItem(
                  icon: Icon(item.icon, size: 18),
                  label: Text(item.label),
                  selected: widget.currentPath.startsWith(item.path),
                  initiallyExpanded: true,
                  onPress: () => context.go(item.path),
                  children: [
                    FSidebarItem(
                      label: const Text('Subjects & Syllabus'),
                      selected:
                          widget.currentPath.startsWith('/curriculum') &&
                          activeTab == CurriculumTab.syllabus,
                      onPress: () {
                        curriculumCubit?.setTab(CurriculumTab.syllabus);
                        context.go('/curriculum');
                      },
                    ),
                    FSidebarItem(
                      label: const Text('Boards & Levels'),
                      selected:
                          widget.currentPath.startsWith('/curriculum') &&
                          activeTab == CurriculumTab.boardsAndLevels,
                      onPress: () {
                        curriculumCubit?.setTab(CurriculumTab.boardsAndLevels);
                        context.go('/curriculum');
                      },
                    ),
                  ],
                )
              else
                FSidebarItem(
                  icon: Icon(item.icon, size: 18),
                  label: Text(item.label),
                  selected: widget.currentPath.startsWith(item.path),
                  onPress: () => context.go(item.path),
                ),
          ],
        ),
        FSidebarGroup(
          label: const Text('Workspace'),
          children: [
            FSidebarItem(
              icon: Icon(
                isDark ? FPhosphorIcons.sun : FPhosphorIcons.moon,
                size: 18,
              ),
              label: Text(isDark ? 'Light Theme' : 'Dark Theme'),
              onPress: () => _safeThemeCubit(context)?.toggle(),
            ),
            FSidebarItem(
              icon: const Icon(FPhosphorIcons.shieldCheck, size: 18),
              label: Text(widget.adminUser.role.label),
              onPress: () => context.go('/settings'),
            ),
          ],
        ),
      ],
    );

    return FScaffold(
      childPad: false,
      sidebar: isDesktop && !_sidebarCollapsed
          ? SizedBox(width: 248, child: sidebar)
          : null,
      header: !isDesktop || _sidebarCollapsed
          ? FHeader(
              title: Text(isDesktop ? 'ChapterNo Admin' : activeItem.label),
              suffixes: [
                FHeaderAction(
                  icon: Icon(
                    isDark ? FPhosphorIcons.sun : FPhosphorIcons.moon,
                    size: 18,
                  ),
                  semanticsLabel: isDark
                      ? 'Switch to light mode'
                      : 'Switch to dark mode',
                  onPress: () => _safeThemeCubit(context)?.toggle(),
                ),
                if (isDesktop)
                  FHeaderAction(
                    icon: const Icon(FPhosphorIcons.list, size: 18),
                    semanticsLabel: 'Expand sidebar',
                    onPress: () => setState(() => _sidebarCollapsed = false),
                  )
                else
                  FHeaderAction(
                    icon: const Icon(FPhosphorIcons.signOut, size: 18),
                    semanticsLabel: 'Sign Out',
                    onPress: widget.onSignOut,
                  ),
              ],
            )
          : null,
      footer: !isDesktop
          ? FBottomNavigationBar(
              index: activeIndex < 0 ? 0 : activeIndex,
              onChange: (index) => context.go(kAdminNavItems[index].path),
              children: [
                for (final item in kAdminNavItems)
                  FBottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
              ],
            )
          : null,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 28 : 16),
        child: widget.child,
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
