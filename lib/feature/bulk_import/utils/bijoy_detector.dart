// Heuristic detector for legacy Bijoy ANSI Bangla and double-encoded UTF-8.
// Deliberately ignores ASCII LaTeX symbols ($ \ ^ _ { }) and Unicode Bangla,
// so Physics/Chemistry equations never trigger a false positive.

abstract final class BijoyDetector {
  // Latin-1 Supplement characters that legitimately appear in science text.
  static const Set<String> _safeLatin1 = {
    '°', '±', '²', '³', '¹', 'µ', '·', '¼', '½', '¾', '×', '÷', '¬', '§',
  };

  /// Returns a row-level error message when [text] looks like legacy Bijoy
  /// ANSI or mojibake Bangla, or null when the text is clean.
  static String? check(String? text) {
    if (text == null || text.isEmpty) return null;

    var replacementChars = 0;
    var mojibakePairs = 0;
    var suspiciousLatin1 = 0;
    final runes = text.runes.toList();

    for (var i = 0; i < runes.length; i++) {
      final rune = runes[i];
      if (rune == 0xFFFD) {
        replacementChars++;
      } else if (rune >= 0x80 &&
          rune <= 0xFF &&
          !_safeLatin1.contains(String.fromCharCode(rune))) {
        suspiciousLatin1++;
      }
      // UTF-8 Bangla mis-decoded as Windows-1252 shows "à¦" / "à§" pairs.
      if (rune == 0xE0 &&
          i + 1 < runes.length &&
          (runes[i + 1] == 0xA6 || runes[i + 1] == 0xA7)) {
        mojibakePairs++;
      }
    }

    if (replacementChars > 0) {
      return _message('undecodable ANSI bytes');
    }
    if (mojibakePairs > 0) {
      return _message('double-encoded Bangla (UTF-8 saved as ANSI)');
    }
    if (suspiciousLatin1 >= 2) {
      return _message('ANSI-only characters');
    }
    return null;
  }

  static String _message(String cause) =>
      'Legacy Bijoy ANSI text detected ($cause). Re-export the sheet as UTF-8 CSV and import again.';
}
