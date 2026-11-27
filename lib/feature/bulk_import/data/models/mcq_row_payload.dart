// Builds the upsert_mcq_batch JSON payload for one validated row.
// Sends bigint chapter/subject ids as ints and board_id as a uuid string.
import 'imports/mcq_row_payload_imports.dart';

Map<String, dynamic> buildMcqRowPayload(
  McqRowDraft draft, {
  required int subjectId,
  String? defaultBoardId,
}) {
  return <String, dynamic>{
    'external_code': ?draft.externalCode,
    'title': draft.title,
    'options': [
      for (final option in draft.options)
        {'key': option.key, 'text': option.text},
    ],
    'correct_ans': draft.correctAns,
    'level': draft.level,
    'explanation': ?draft.explanation,
    'chapter_id': draft.resolvedChapterId,
    'subject_id': subjectId,
    'board_id': ?defaultBoardId,
    'exam_year': ?draft.examYear,
  };
}
