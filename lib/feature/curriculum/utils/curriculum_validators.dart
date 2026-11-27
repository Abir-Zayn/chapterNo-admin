// Pure-Dart validators and code slugifier for Curriculum Catalogue forms.
// Enforces UTF-8 Bangla/English required fields and lowercase node codes.

abstract final class CurriculumValidators {
  static final RegExp _codePattern = RegExp(r'^[a-z0-9][a-z0-9_-]*$');

  static String? requiredBangla(String? value, {String label = 'Bangla name'}) {
    if ((value ?? '').trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? requiredEnglish(
    String? value, {
    String label = 'English name',
  }) {
    if ((value ?? '').trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? code(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Code is required.';
    }
    if (!_codePattern.hasMatch(trimmed)) {
      return 'Use lowercase letters, numbers, underscores, or hyphens.';
    }
    return null;
  }

  static String? positiveInt(String? value, {String label = 'Chapter number'}) {
    final trimmed = (value ?? '').trim();
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return '$label must be a positive integer.';
    }
    return null;
  }

  static String? nonNegativeInt(
    String? value, {
    String label = 'Display order',
  }) {
    final trimmed = (value ?? '').trim();
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return '$label must be 0 or greater.';
    }
    return null;
  }

  static String suggestCode(String nameEn, {String prefix = ''}) {
    final slug = nameEn
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (slug.isEmpty) return prefix.trim();
    if (prefix.trim().isEmpty) return slug;
    final cleanPrefix = prefix
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return '${cleanPrefix}_$slug';
  }
}
