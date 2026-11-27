// Solid 1dp-bordered status badges for editorial workflow and admin roles.
// Avoids translucent glass effects while keeping strong contrast.
import 'status_badges_imports.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
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

  factory StatusBadge.neutral(String label) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.surfaceSubtle,
      foregroundColor: AppColors.textSecondary,
      borderColor: AppColors.border,
    );
  }

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
