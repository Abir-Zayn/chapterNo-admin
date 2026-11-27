// Admin workspace settings view with appearance toggle and verified profile.
// Never exposes secret keys; offers theme switch and explicit sign-out action.
import 'imports/settings_screen_imports.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.envConfig});

  final EnvConfig envConfig;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final text = context.theme.typography.body;
    final admin = context.select((AuthCubit cubit) => cubit.state.adminUser);
    final themeMode = _safeThemeMode(context);

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Workspace Settings',
                style: text.xl2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Verified administrator session, theme, and Supabase configuration.',
                style: text.sm.copyWith(color: colors.mutedForeground),
              ),
              const SizedBox(height: 20),
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(FPhosphorIcons.circleHalf, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Appearance',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FButton(
                            variant: themeMode == ThemeMode.light
                                ? .primary
                                : .outline,
                            size: .sm,
                            mainAxisSize: .min,
                            prefix: const Icon(FPhosphorIcons.sun, size: 16),
                            onPress: () => _safeThemeCubit(
                              context,
                            )?.setMode(ThemeMode.light),
                            child: const Text('Light'),
                          ),
                          FButton(
                            variant: themeMode == ThemeMode.dark
                                ? .primary
                                : .outline,
                            size: .sm,
                            mainAxisSize: .min,
                            prefix: const Icon(FPhosphorIcons.moon, size: 16),
                            onPress: () => _safeThemeCubit(
                              context,
                            )?.setMode(ThemeMode.dark),
                            child: const Text('Dark'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(FPhosphorIcons.shieldCheck, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Verified Admin Identity',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          if (admin != null)
                            StatusBadge.neutral(admin.role.label),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const FDivider(),
                      const SizedBox(height: 14),
                      _InfoRow(
                        label: 'Display Name',
                        value: admin?.displayName ?? '-',
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'Email', value: admin?.email ?? '-'),
                      const SizedBox(height: 10),
                      _InfoRow(label: 'API Host', value: envConfig.apiHost),
                      const SizedBox(height: 18),
                      FButton(
                        variant: .outline,
                        mainAxisSize: .min,
                        prefix: const Icon(FPhosphorIcons.signOut, size: 16),
                        onPress: () => context.read<AuthCubit>().signOut(),
                        child: const Text('Sign Out'),
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(color: colors.mutedForeground, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colors.foreground,
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}
