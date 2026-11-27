// Bulk input parser tests: CSV/JSON sniffing, header aliases, JSON shapes.
import 'package:chapterno_admin/feature/bulk_import/utils/bulk_input_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const _csvHeader =
    'external_code,title,option_1,option_2,option_3,option_4,'
    'correct_ans,level,explaination,chapter_code,exam_year';

void main() {
  group('parseBulkInput CSV', () {
    test('normalizes explaination typo and keeps l4 level rows', () {
      final parsed = parseBulkInput(
        '$_csvHeader\n'
        'SMK-1,কোনটি সঠিক?,১০,২০,৩০,৪০,2,l4,ব্যাখ্যা,ch01,2025',
      );
      expect(parsed.isOk, isTrue);
      expect(parsed.rows, hasLength(1));
      final row = parsed.rows.first;
      expect(row['explanation'], 'ব্যাখ্যা');
      expect(row.containsKey('explaination'), isFalse);
      expect(row['level'], 'l4');
      expect(row['title'], 'কোনটি সঠিক?');
    });

    test('rejects a CSV header without a title column', () {
      final parsed = parseBulkInput('external_code,option_1\nSMK-1,x');
      expect(parsed.isOk, isFalse);
      expect(parsed.parseError, contains('title'));
    });

    test('pads short rows with empty cells', () {
      final parsed = parseBulkInput('title,option_1\nশুধু শিরোনাম');
      expect(parsed.rows.first['option_1'], '');
    });
  });

  group('parseBulkInput JSON', () {
    test('parses an array of row objects with alias keys', () {
      final parsed = parseBulkInput(
        '[{"external_code": "SMK-1", "title": "প্রশ্ন", '
            '"options": ["ক", "খ", "গ", "ঘ"], "correct_option": "1", '
            '"level": "l3", "explaination": "ব্যাখ্যা", '
            '"chapter_code": "ch01"}]',
      );
      expect(parsed.isOk, isTrue);
      final row = parsed.rows.single;
      expect(row['correct_ans'], '1');
      expect(row['explanation'], 'ব্যাখ্যা');
      expect(row['options'], isA<List<dynamic>>());
    });

    test('wraps a single JSON object into one row', () {
      final parsed = parseBulkInput('{"title": "একক প্রশ্ন"}');
      expect(parsed.rows, hasLength(1));
      expect(parsed.rows.first['title'], 'একক প্রশ্ন');
    });

    test('rejects invalid JSON with a parse error', () {
      final parsed = parseBulkInput('[{"title": broken');
      expect(parsed.isOk, isFalse);
      expect(parsed.parseError, contains('Invalid JSON'));
    });

    test('rejects JSON rows that are not objects', () {
      final parsed = parseBulkInput('["just a string"]');
      expect(parsed.isOk, isFalse);
      expect(parsed.parseError, contains('not an object'));
    });

    test('rejects a non-array, non-object JSON scalar', () {
      final parsed = parseBulkInput('42');
      expect(parsed.isOk, isFalse);
    });
  });

  test('empty input is rejected', () {
    expect(parseBulkInput('   ').parseError, 'Input is empty.');
  });
}
