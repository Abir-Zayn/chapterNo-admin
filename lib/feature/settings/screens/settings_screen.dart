// Admin workspace settings view displaying verified profile and project host.
// Never exposes secret keys; offers explicit sign-out action.
import 'settings_screen_imports.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.envConfig});

  final EnvConfig envConfig;

  @override
  Widget build(BuildContext context) {
    final admin = context.select((AuthCubit cubit) => cubit.state.adminUser);

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
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
              'Verified administrator session and Supabase project configuration.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
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
                      if (admin != null) StatusBadge.neutral(admin.role.label),
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
                    label: 'Supabase Host',
                    value: envConfig.projectHost,
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}
