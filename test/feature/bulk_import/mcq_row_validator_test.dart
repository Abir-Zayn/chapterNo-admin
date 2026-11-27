// MCQ row validator tests: field rules, chapter resolution, batch duplicates.
import 'package:chapterno_admin/feature/bulk_import/domain/entities/mcq_row_draft.dart';
import 'package:chapterno_admin/feature/bulk_import/utils/mcq_row_validator.dart';
import 'package:flutter_test/flutter_test.dart';

McqRowValidationContext _context({
  Map<String, int> chapterIdsByCode = const {'ch01': 101},
  int? defaultChapterId,
}) => McqRowValidationContext(
  chapterIdsByCode: chapterIdsByCode,
  defaultChapterId: defaultChapterId,
);

Map<String, dynamic> _validRow() => <String, dynamic>{
  'external_code': 'SMK-1',
  'title': 'কোনটি সঠিক?',
  'option_1': '১০',
  'option_2': '২০',
  'option_3': '৩০',
  'option_4': '৪০',
  'correct_ans': '2',
  'level': 'l4',
  'explanation': 'ব্যাখ্যা',
  'chapter_code': 'ch01',
  'exam_year': '2025',
};

void main() {
  group('McqRowValidator.validate happy paths', () {
    test('valid row passes and resolves its chapter_id', () {
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, _validRow())],
        _context(),
      );
      expect(drafts.single.isValid, isTrue, reason: '${drafts.single.errors}');
      expect(drafts.single.resolvedChapterId, 101);
    });

    test('row without chapter_code falls back to the default chapter', () {
      final row = _validRow()..remove('chapter_code');
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(defaultChapterId: 202),
      );
      expect(drafts.single.isValid, isTrue);
      expect(drafts.single.resolvedChapterId, 202);
    });

    test('JSON options with explicit keys validate against correct_ans', () {
      final row = _validRow()
        ..['options'] = [
          {'key': 'a', 'text': 'ক'},
          {'key': 'b', 'text': 'খ'},
        ]
        ..['correct_ans'] = 'b';
      row.remove('option_1');
      row.remove('option_2');
      row.remove('option_3');
      row.remove('option_4');
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.isValid, isTrue);
    });
  });

  group('McqRowValidator.validate row-level errors', () {
    test('missing title is reported', () {
      final row = _validRow()..['title'] = '';
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, contains(contains('title')));
    });

    test('correct_ans that matches no option key is reported', () {
      final row = _validRow()..['correct_ans'] = '9';
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, anyElement(contains('correct_ans')));
    });

    test('unknown chapter_code is reported', () {
      final row = _validRow()..['chapter_code'] = 'ch99';
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, anyElement(contains('ch99')));
    });

    test('missing chapter_code without a default chapter is reported', () {
      final row = _validRow()..remove('chapter_code');
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, anyElement(contains('chapter_code')));
    });

    test('missing external_code is reported', () {
      final row = _validRow()..remove('external_code');
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, anyElement(contains('external_code')));
    });

    test('duplicate external_code within the batch is reported once', () {
      final drafts = McqRowValidator.validate(
        [
          McqRowDraft.fromParsedRow(1, _validRow()),
          McqRowDraft.fromParsedRow(2, _validRow()),
        ],
        _context(),
      );
      expect(drafts.first.isValid, isTrue);
      expect(drafts.last.errors, anyElement(contains('Duplicate')));
    });

    test('invalid level is reported', () {
      final row = _validRow()..['level'] = 'hard';
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, anyElement(contains('level')));
    });

    test('fewer than two non-empty options is reported', () {
      final row = _validRow()
        ..['option_2'] = ''
        ..['option_3'] = ''
        ..['option_4'] = ''
        ..['correct_ans'] = '1';
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, anyElement(contains('options')));
    });

    test('exam_year outside the allowed range is reported', () {
      final row = _validRow()..['exam_year'] = '1800';
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, anyElement(contains('exam_year')));
    });

    test('Bijoy ANSI text in the title is reported', () {
      final row = _validRow()..['title'] = 'à¦à§à¦¿à¦¬';
      final drafts = McqRowValidator.validate(
        [McqRowDraft.fromParsedRow(1, row)],
        _context(),
      );
      expect(drafts.single.errors, anyElement(contains('Bijoy')));
    });
  });
}
