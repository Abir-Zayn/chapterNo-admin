// Placeholder screen for upcoming M3-M5 admin routes.
// Displays milestone summary, active route purpose, and theme-aware surface.
import 'imports/milestone_placeholder_screen_imports.dart';

class MilestonePlaceholderScreen extends StatelessWidget {
  const MilestonePlaceholderScreen({
    super.key,
    required this.title,
    required this.milestoneCode,
    required this.description,
    required this.icon,
  });

  final String title;
  final String milestoneCode;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      child: Icon(icon, size: 20, color: colors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.theme.typography.body.xl2.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          StatusBadge.neutral(milestoneCode),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: context.theme.typography.body.md.copyWith(
                    color: colors.mutedForeground,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
