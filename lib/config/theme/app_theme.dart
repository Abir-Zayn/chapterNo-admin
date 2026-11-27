// Black-and-white academic theme tokens, AppPalette ThemeExtension, and light/dark themes.
// Enforces solid surfaces, 1dp borders, high-contrast chips/badges, and zero blur.
import 'imports/app_theme_imports.dart';

abstract final class AppColors {
  static const Color canvas = Color(0xFFFCFCFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF7F7F6);
  static const Color border = Color(0xFFE4E4E7);
  static const Color primary = Color(0xFF18181B);
  static const Color primaryHover = Color(0xFF27272A);
  static const Color primaryTint = Color(0xFFF4F4F5);
  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF71717A);
  static const Color success = Color(0xFF16A34A);
  static const Color successTint = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFD97706);
  static const Color warningTint = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626);
  static const Color errorTint = Color(0xFFFEF2F2);
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.primaryTint,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.successTint,
    required this.successBorder,
    required this.warning,
    required this.warningTint,
    required this.warningBorder,
    required this.error,
    required this.errorTint,
  });

  static const AppPalette light = AppPalette(
    canvas: Color(0xFFFCFCFB),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF7F7F6),
    border: Color(0xFFE4E4E7),
    primary: Color(0xFF18181B),
    onPrimary: Color(0xFFFFFFFF),
    primaryTint: Color(0xFFF4F4F5),
    textPrimary: Color(0xFF18181B),
    textSecondary: Color(0xFF71717A),
    success: Color(0xFF16A34A),
    successTint: Color(0xFFF0FDF4),
    successBorder: Color(0xFFBBF7D0),
    warning: Color(0xFFD97706),
    warningTint: Color(0xFFFFFBEB),
    warningBorder: Color(0xFFFDE68A),
    error: Color(0xFFDC2626),
    errorTint: Color(0xFFFEF2F2),
  );

  static const AppPalette dark = AppPalette(
    canvas: Color(0xFF09090B),
    surface: Color(0xFF18181B),
    surfaceSubtle: Color(0xFF27272A),
    border: Color(0xFF27272A),
    primary: Color(0xFFFAFAFA),
    onPrimary: Color(0xFF09090B),
    primaryTint: Color(0xFF27272A),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFFA1A1AA),
    success: Color(0xFF4ADE80),
    successTint: Color(0xFF0F291A),
    successBorder: Color(0xFF166534),
    warning: Color(0xFFFBBF24),
    warningTint: Color(0xFF2A1F0A),
    warningBorder: Color(0xFF92400E),
    error: Color(0xFFF87171),
    errorTint: Color(0xFF2A1215),
  );

  final Color canvas;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color primary;
  final Color onPrimary;
  final Color primaryTint;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color successTint;
  final Color successBorder;
  final Color warning;
  final Color warningTint;
  final Color warningBorder;
  final Color error;
  final Color errorTint;

  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>() ?? light;
  }

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceSubtle,
    Color? border,
    Color? primary,
    Color? onPrimary,
    Color? primaryTint,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? successTint,
    Color? successBorder,
    Color? warning,
    Color? warningTint,
    Color? warningBorder,
    Color? error,
    Color? errorTint,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryTint: primaryTint ?? this.primaryTint,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      successTint: successTint ?? this.successTint,
      successBorder: successBorder ?? this.successBorder,
      warning: warning ?? this.warning,
      warningTint: warningTint ?? this.warningTint,
      warningBorder: warningBorder ?? this.warningBorder,
      error: error ?? this.error,
      errorTint: errorTint ?? this.errorTint,
    );
  }

  @override
  AppPalette lerp(covariant ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      successTint: Color.lerp(successTint, other.successTint, t)!,
      successBorder: Color.lerp(successBorder, other.successBorder, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorTint: Color.lerp(errorTint, other.errorTint, t)!,
    );
  }
}

abstract final class AppTypography {
  /// Returns Hind Siliguri text style for UTF-8 Bangla preview and content fields.
  static TextStyle bangla({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double height = 1.55,
  }) {
    return GoogleFonts.hindSiliguri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppPalette.light);

  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final baseText = GoogleFonts.interTextTheme();
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.primary,
      onSecondary: palette.onPrimary,
      secondaryContainer: palette.primaryTint,
      onSecondaryContainer: palette.textPrimary,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      error: palette.error,
      onError: palette.onPrimary,
      outline: palette.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: [palette],
      scaffoldBackgroundColor: palette.canvas,
      textTheme: baseText.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: palette.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: TextStyle(color: palette.textSecondary),
        hintStyle: TextStyle(color: palette.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: palette.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          backgroundColor: palette.surface,
          side: BorderSide(color: palette.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.primary,
        disabledColor: palette.surfaceSubtle,
        checkmarkColor: palette.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.border,
          ),
        ),
        labelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            fontSize: 13,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? palette.onPrimary
                : palette.textPrimary,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.primary
                : palette.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.onPrimary
                : palette.textPrimary,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? palette.onPrimary
                : palette.textPrimary,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: palette.border)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}
