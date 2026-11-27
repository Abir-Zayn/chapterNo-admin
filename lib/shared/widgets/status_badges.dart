// Solid 1dp-bordered status badges for editorial workflow and admin roles.
// Avoids translucent glass effects while adapting cleanly to light/dark themes.
import 'imports/status_badges_imports.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.isActive = false,
  });

  factory StatusBadge.rights(String rightsStatus) {
    if (rightsStatus == 'cleared') {
      return const StatusBadge(
        label: 'Cleared',
        backgroundColor: AppColors.successTint,
        foregroundColor: AppColors.success,
        borderColor: Color(0xFFBBF7D0),
      );
    }
    return const StatusBadge(
      label: 'Internal Draft',
      backgroundColor: AppColors.warningTint,
      foregroundColor: AppColors.warning,
      borderColor: Color(0xFFFDE68A),
    );
  }

  factory StatusBadge.neutral(String label) => StatusBadge(label: label);

  factory StatusBadge.active(String label) =>
      StatusBadge(label: label, isActive: true);

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final bg =
        backgroundColor ?? (isActive ? palette.primary : palette.surfaceSubtle);
    final fg =
        foregroundColor ??
        (isActive ? palette.onPrimary : palette.textSecondary);
    final border = borderColor ?? (isActive ? palette.primary : palette.border);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
