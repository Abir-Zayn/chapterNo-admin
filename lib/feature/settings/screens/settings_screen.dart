// Admin workspace settings view with appearance toggle and verified profile.
// Never exposes secret keys; offers theme switch and explicit sign-out action.
import 'imports/settings_screen_imports.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.envConfig});

  final EnvConfig envConfig;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
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
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Verified administrator session, theme, and Supabase configuration.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: palette.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsRegular.circleHalf, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Appearance',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(PhosphorIconsRegular.sun, size: 16),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(PhosphorIconsRegular.moon, size: 16),
                          label: Text('Dark'),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (values) =>
                          _safeThemeCubit(context)?.setMode(values.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsRegular.shieldCheck, size: 18),
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
                    const Divider(),
                    const SizedBox(height: 14),
                    _InfoRow(
                      label: 'Display Name',
                      value: admin?.displayName ?? '-',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Email', value: admin?.email ?? '-'),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'API Host',
                      value: envConfig.apiHost,
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () => context.read<AuthCubit>().signOut(),
                      icon: const Icon(PhosphorIconsRegular.signOut, size: 16),
                      label: const Text('Sign Out'),
                    ),
                  ],
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
    final palette = AppPalette.of(context);
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(color: palette.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}
