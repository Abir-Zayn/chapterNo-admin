import 'package:chapterno_admin/feature/question_bank/data/models/mcq_question_model.dart';
import 'package:chapterno_admin/feature/question_bank/types/question_bank_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('McqQuestionModel.fromJson', () {
    test('parses bigint curriculum FKs, options JSONB, and board provenance', () {
      final model = McqQuestionModel.fromJson({
        'id': '11111111-1111-1111-1111-111111111111',
        'external_code': 'SSC-PHY-CH02-005',
        'subject_id': 1,
        'chapter_id': 2,
        'topic_id': 14,
        'stimulus_id': null,
        'question_type': 'simple',
        'title': r'গতিশক্তি $E_k = \frac{1}{2}mv^2$',
        'statements': null,
        'options': [
          {'key': '1', 'text': 'ক'},
          {'key': '2', 'text': 'খ'},
          {'key': '3', 'text': 'গ'},
          {'key': '4', 'text': 'ঘ'},
        ],
        'correct_option': '4',
        'explanation': 'ব্যাখ্যা',
        'difficulty': 'l2',
        'source_type': 'board',
        'board_id': '22222222-2222-2222-2222-222222222222',
        'exam_year': 2024,
        'rights_status': 'public_board',
        'status': 'draft',
        'is_verified': false,
        'version': 2,
        'archived_at': null,
        'created_at': '2026-11-28T00:00:00Z',
        'updated_at': '2026-11-28T01:00:00Z',
      });

      expect(model.id, '11111111-1111-1111-1111-111111111111');
      expect(model.externalCode, 'SSC-PHY-CH02-005');
      expect(model.subjectId, 1);
      expect(model.chapterId, 2);
      expect(model.topicId, 14);
      expect(model.options.length, 4);
      expect(model.options[3].key, '4');
      expect(model.correctOption, '4');
      expect(model.sourceType, McqSourceType.board);
      expect(model.rightsStatus, McqRightsStatus.publicBoard);
      expect(model.status, McqStatus.draft);
      expect(model.examYear, 2024);
      expect(model.version, 2);
      expect(model.isFrozenForEditor, isFalse);
    });

    test('parses multiple_completion statements and string-encoded bigint ids', () {
      final model = McqQuestionModel.fromJson({
        'id': '33333333-3333-3333-3333-333333333333',
        'subject_id': '7',
        'chapter_id': '12',
        'question_type': 'multiple_completion',
        'title': 'নিচের কোনটি সঠিক?',
        'statements': ['বেগ ভেক্টর রাশি', 'দ্রুতি স্কেলার রাশি'],
        'options': ['i ও ii', 'i ও iii'],
        'correct_option': '1',
        'status': 'published',
        'is_verified': true,
      });

      expect(model.subjectId, 7);
      expect(model.chapterId, 12);
      expect(model.questionType, McqQuestionType.multipleCompletion);
      expect(model.statements, ['বেগ ভেক্টর রাশি', 'দ্রুতি স্কেলার রাশি']);
      expect(model.options.first.key, '1');
      expect(model.isFrozenForEditor, isTrue);
    });
  });
}
