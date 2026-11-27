// Hind Siliguri text style for UTF-8 Bangla preview and content fields.
import 'imports/app_typography_imports.dart';

abstract final class AppTypography {
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
