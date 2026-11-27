// Pure-Dart enums for the bulk importer: input mode, MCQ level, row filters.
// Mirrors the server-side level contract (l1-l4) and UI view states.

enum ImportInputMode {
  file('Upload file'),
  paste('Paste CSV / JSON');

  const ImportInputMode(this.label);

  final String label;
}

enum McqLevel {
  l1('Low'),
  l2('Medium'),
  l3('Hard'),
  l4('Board');

  const McqLevel(this.label);

  final String label;

  static McqLevel? tryParse(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    for (final level in McqLevel.values) {
      if (level.name == value) return level;
    }
    return null;
  }
}

enum RowViewFilter {
  all('All rows'),
  validOnly('Valid'),
  errorOnly('Errors');

  const RowViewFilter(this.label);

  final String label;
}
