// Normalizes pasted or file text into raw MCQ row maps.
// Sniffs JSON arrays/objects first, then falls back to RFC 4180 CSV parsing.
// Accepts the product-readme.csv "explaination" typo and correct_option alias.
import 'imports/bulk_input_parser_imports.dart';
import 'csv_parser.dart';

class ParsedBulkInput {
  const ParsedBulkInput({required this.rows, this.parseError});

  final List<Map<String, dynamic>> rows;
  final String? parseError;

  bool get isOk => parseError == null;
}

ParsedBulkInput parseBulkInput(String source) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) {
    return const ParsedBulkInput(rows: [], parseError: 'Input is empty.');
  }
  if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
    return _parseJson(trimmed);
  }
  return _parseCsv(trimmed);
}

ParsedBulkInput _parseJson(String source) {
  final dynamic decoded;
  try {
    decoded = jsonDecode(source);
  } catch (error) {
    return ParsedBulkInput(rows: const [], parseError: 'Invalid JSON: $error');
  }
  dynamic list = decoded;
  if (list is Map) {
    list = <dynamic>[list];
  }
  if (list is! List) {
    return const ParsedBulkInput(
      rows: [],
      parseError: 'JSON input must be an array of MCQ row objects.',
    );
  }
  final rows = <Map<String, dynamic>>[];
  var rowIndex = 0;
  for (final entry in list) {
    rowIndex++;
    if (entry is Map) {
      rows.add(_normalizeKeys(entry));
    } else {
      return ParsedBulkInput(
        rows: const [],
        parseError: 'JSON row $rowIndex is not an object.',
      );
    }
  }
  return ParsedBulkInput(rows: rows);
}

ParsedBulkInput _parseCsv(String source) {
  final table = parseCsvTable(source);
  if (table.isEmpty) {
    return const ParsedBulkInput(rows: [], parseError: 'No CSV rows found.');
  }
  final header = table.first.map(_normalizeHeader).toList();
  if (!header.contains('title')) {
    return const ParsedBulkInput(
      rows: [],
      parseError:
          'CSV header must include a title column. Expected: '
          'external_code,title,option_1,option_2,option_3,option_4,'
          'correct_ans,level,explanation,chapter_code,exam_year',
    );
  }
  final rows = <Map<String, dynamic>>[];
  for (final cells in table.skip(1)) {
    final row = <String, dynamic>{};
    for (var i = 0; i < header.length; i++) {
      row[header[i]] = i < cells.length ? cells[i] : '';
    }
    rows.add(row);
  }
  return ParsedBulkInput(rows: rows);
}

String _normalizeHeader(String raw) {
  final key = raw.trim().toLowerCase().replaceAll(' ', '_');
  return switch (key) {
    'explaination' => 'explanation',
    'correct_option' => 'correct_ans',
    _ => key,
  };
}

Map<String, dynamic> _normalizeKeys(Map<dynamic, dynamic> map) {
  return {
    for (final entry in map.entries)
      _normalizeHeader(entry.key.toString()): entry.value,
  };
}
