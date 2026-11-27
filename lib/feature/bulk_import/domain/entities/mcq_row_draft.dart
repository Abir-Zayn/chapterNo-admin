// Domain draft of one parsed MCQ row with options and source row number.
// Validation errors and chapter resolution are attached by McqRowValidator.
import 'imports/mcq_row_draft_imports.dart';

class McqOptionDraft extends Equatable {
  const McqOptionDraft({required this.key, required this.text});

  /// "1".."n" for plain CSV cells, or the explicit key of a JSON option object.
  final String key;
  final String text;

  bool get isBlank => text.trim().isEmpty;

  @override
  List<Object?> get props => [key, text];
}

class McqRowDraft extends Equatable {
  const McqRowDraft({
    required this.rowNumber,
    required this.title,
    required this.options,
    required this.correctAns,
    required this.level,
    this.externalCode,
    this.explanation,
    this.chapterCode,
    this.examYearRaw = '',
    this.examYear,
    this.resolvedChapterId,
    this.errors = const [],
  });

  factory McqRowDraft.fromParsedRow(int rowNumber, Map<String, dynamic> row) {
    final options = <McqOptionDraft>[];
    final rawOptions = row['options'];
    if (rawOptions is List && rawOptions.isNotEmpty) {
      for (final entry in rawOptions) {
        if (entry is Map && entry['key'] != null) {
          options.add(
            McqOptionDraft(
              key: entry['key'].toString().trim(),
              text: (entry['text'] ?? '').toString().trim(),
            ),
          );
        } else {
          options.add(
            McqOptionDraft(
              key: (options.length + 1).toString(),
              text: entry.toString().trim(),
            ),
          );
        }
      }
    } else {
      for (var i = 1; i <= 4; i++) {
        final cell = row['option_$i'];
        if (cell != null) {
          options.add(McqOptionDraft(key: '$i', text: cell.toString().trim()));
        }
      }
    }

    final examYearRaw = (row['exam_year'] ?? '').toString().trim();
    return McqRowDraft(
      rowNumber: rowNumber,
      externalCode: _trimOrNull(row['external_code']),
      title: (row['title'] ?? '').toString().trim(),
      options: options,
      correctAns: (row['correct_ans'] ?? '').toString().trim(),
      level: (row['level'] ?? '').toString().trim().toLowerCase(),
      explanation: _trimOrNull(row['explanation']),
      chapterCode: _trimOrNull(row['chapter_code']),
      examYearRaw: examYearRaw,
      examYear: examYearRaw.isEmpty ? null : int.tryParse(examYearRaw),
    );
  }

  /// 1-based source row number, for stable preview references.
  final int rowNumber;
  final String? externalCode;
  final String title;
  final List<McqOptionDraft> options;
  final String correctAns;
  final String level;
  final String? explanation;
  final String? chapterCode;
  final String examYearRaw;
  final int? examYear;

  /// Resolved bigint chapters.id, set during validation.
  final int? resolvedChapterId;
  final List<String> errors;

  bool get isValid => errors.isEmpty;
  int get nonEmptyOptionCount =>
      options.where((option) => !option.isBlank).length;

  McqRowDraft copyWith({List<String>? errors, int? resolvedChapterId}) {
    return McqRowDraft(
      rowNumber: rowNumber,
      externalCode: externalCode,
      title: title,
      options: options,
      correctAns: correctAns,
      level: level,
      explanation: explanation,
      chapterCode: chapterCode,
      examYearRaw: examYearRaw,
      examYear: examYear,
      resolvedChapterId: resolvedChapterId ?? this.resolvedChapterId,
      errors: errors ?? this.errors,
    );
  }

  static String? _trimOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  @override
  List<Object?> get props => [
    rowNumber,
    externalCode,
    title,
    options,
    correctAns,
    level,
    explanation,
    chapterCode,
    examYearRaw,
    examYear,
    resolvedChapterId,
    errors,
  ];
}
