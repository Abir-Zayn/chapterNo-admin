// PostgREST row deserializer for public.mcq_questions (bigint curriculum FKs).
import 'imports/mcq_question_model_imports.dart';

abstract final class McqQuestionModel {
  static McqQuestion fromJson(Map<String, dynamic> map) {
    return McqQuestion(
      id: (map['id'] ?? '').toString(),
      externalCode: _nullableString(map['external_code']),
      subjectId: _parseInt(map['subject_id']) ?? 0,
      chapterId: _parseInt(map['chapter_id']) ?? 0,
      topicId: _parseInt(map['topic_id']),
      stimulusId: _nullableString(map['stimulus_id']),
      questionType: McqQuestionType.fromDbValue(
        map['question_type']?.toString(),
      ),
      title: (map['title'] ?? '').toString(),
      statements: _parseStatements(map['statements']),
      options: _parseOptions(map['options']),
      correctOption: (map['correct_option'] ?? '').toString(),
      explanation: _nullableString(map['explanation']),
      difficulty: McqDifficulty.fromDbValue(map['difficulty']?.toString()),
      sourceType: McqSourceType.fromDbValue(map['source_type']?.toString()),
      boardId: _nullableString(map['board_id']),
      examYear: _parseInt(map['exam_year']),
      rightsStatus: McqRightsStatus.fromDbValue(
        map['rights_status']?.toString(),
      ),
      status: McqStatus.fromDbValue(map['status']?.toString()),
      isVerified: map['is_verified'] == true,
      version: _parseInt(map['version']) ?? 1,
      archivedAt: _parseDate(map['archived_at']),
      createdAt: _parseDate(map['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDate(map['updated_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<McqOption> _parseOptions(Object? raw) {
    if (raw is! List) return const [];
    final result = <McqOption>[];
    for (var i = 0; i < raw.length; i++) {
      final entry = raw[i];
      if (entry is Map) {
        final key = (entry['key'] ?? '${i + 1}').toString();
        final text = (entry['text'] ?? '').toString();
        result.add(McqOption(key: key, text: text));
      } else if (entry != null) {
        result.add(McqOption(key: '${i + 1}', text: entry.toString()));
      }
    }
    return result;
  }

  static List<String> _parseStatements(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .where((item) => item != null && item.toString().trim().isNotEmpty)
        .map((item) => item.toString())
        .toList();
  }

  static String? _nullableString(Object? raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _parseInt(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }
}
