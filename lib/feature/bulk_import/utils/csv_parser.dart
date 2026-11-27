// Pure-Dart RFC 4180 CSV parser.
// Handles quoted commas, doubled quotes, embedded newlines, CRLF/LF, and BOM.

List<List<String>> parseCsvTable(String source) {
  var text = source;
  if (text.startsWith('\uFEFF')) {
    text = text.substring(1); // Google Sheets prepends a UTF-8 BOM.
  }

  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;
  var i = 0;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    rows.add(row);
    row = <String>[];
  }

  while (i < text.length) {
    final char = text[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"'); // Escaped quote inside a quoted field.
          i += 2;
          continue;
        }
        inQuotes = false;
        i++;
        continue;
      }
      field.write(char);
      i++;
      continue;
    }
    if (char == '"') {
      inQuotes = true;
      i++;
      continue;
    }
    if (char == ',') {
      endField();
      i++;
      continue;
    }
    if (char == '\r' || char == '\n') {
      if (char == '\r' && i + 1 < text.length && text[i + 1] == '\n') {
        i++;
      }
      endRow();
      i++;
      continue;
    }
    field.write(char);
    i++;
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    endRow();
  }

  // Drop rows whose every cell is blank (trailing newline artifacts).
  return rows
      .where((cells) => cells.any((cell) => cell.trim().isNotEmpty))
      .toList();
}
