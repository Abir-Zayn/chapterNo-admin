// RFC 4180 CSV parser tests: quoting, escapes, CRLF, BOM, blank-row drops.
import 'package:chapterno_admin/feature/bulk_import/utils/csv_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseCsvTable', () {
    test('parses simple rows and drops trailing blanks', () {
      final table = parseCsvTable('a,b,c\r\n1,2,3\r\n\r\n');
      expect(table, [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
      ]);
    });

    test('keeps quoted commas inside one cell', () {
      final table = parseCsvTable('plain,"has,comma",tail');
      expect(table.first, ['plain', 'has,comma', 'tail']);
    });

    test('unescapes doubled quotes', () {
      final table = parseCsvTable('"say ""hi"" now",x');
      expect(table.first.first, 'say "hi" now');
    });

    test('keeps embedded newlines inside quoted cells', () {
      final table = parseCsvTable('"line1\nline2",second');
      expect(table.first.first, 'line1\nline2');
      expect(table.first[1], 'second');
    });

    test('strips a UTF-8 BOM from the first header cell', () {
      final table = parseCsvTable('\uFEFFtitle,option_1');
      expect(table.first.first, 'title');
    });

    test('preserves UTF-8 Bangla text verbatim', () {
      final table = parseCsvTable('বাংলা প্রশ্ন,উত্তর');
      expect(table.first.first, 'বাংলা প্রশ্ন');
    });

    test('preserves LaTeX backslashes and math symbols verbatim', () {
      const latex = r'$E_k = \frac{1}{2}mv^2$';
      final table = parseCsvTable('$latex,$latex');
      expect(table.first.first, latex);
    });
  });
}
