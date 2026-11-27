// Solid 1dp-bordered status badges for editorial workflow and admin roles.
// Colors resolve from the Forui theme; success/warning pairs adapt to brightness
// so badge text stays readable in both light and dark mode.
import 'imports/status_badges_imports.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.isActive = false,
  }) : _tone = _StatusTone.custom;

  const StatusBadge._({required this.label, required this._tone})
    : backgroundColor = null,
      foregroundColor = null,
      borderColor = null,
      isActive = false;

  factory StatusBadge.rights(String rightsStatus) {
    if (rightsStatus == 'cleared') {
      return const StatusBadge._(label: 'Cleared', tone: _StatusTone.success);
    }
    return const StatusBadge._(
      label: 'Internal Draft',
      tone: _StatusTone.warning,
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
  final _StatusTone _tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final dark = colors.brightness == Brightness.dark;

    final (bg, fg, border) = switch (_tone) {
      _StatusTone.success => (
        dark ? const Color(0xFF0F291A) : const Color(0xFFF0FDF4),
        dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
        dark ? const Color(0xFF166534) : const Color(0xFFBBF7D0),
      ),
      _StatusTone.warning => (
        dark ? const Color(0xFF2A1F0A) : const Color(0xFFFFFBEB),
        dark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
        dark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
      ),
      _StatusTone.custom => (
        backgroundColor ?? (isActive ? colors.primary : colors.secondary),
        foregroundColor ??
            (isActive ? colors.primaryForeground : colors.mutedForeground),
        borderColor ?? (isActive ? colors.primary : colors.border),
      ),
    };

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

enum _StatusTone { custom, success, warning }
