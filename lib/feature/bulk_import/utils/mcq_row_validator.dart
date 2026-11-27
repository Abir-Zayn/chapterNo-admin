// Pure-Dart row validator for parsed MCQ drafts against curriculum context.
// Enforces title, options, correct_ans, level, chapter resolution, duplicate
// external_code, exam_year range, and the Bijoy ANSI encoding guard.
import 'imports/mcq_row_validator_imports.dart';
import '../domain/entities/mcq_row_draft.dart';
import 'bijoy_detector.dart';

class McqRowValidationContext {
  const McqRowValidationContext({
    required this.chapterIdsByCode,
    this.defaultChapterId,
  });

  /// chapter code (e.g. "ch01") -> bigint chapters.id for the selected subject.
  final Map<String, int> chapterIdsByCode;
  final int? defaultChapterId;
}

abstract final class McqRowValidator {
  static List<McqRowDraft> validate(
    List<McqRowDraft> drafts,
    McqRowValidationContext context,
  ) {
    final seenExternalCodes = <String>{};
    return [
      for (final draft in drafts)
        _validateRow(draft, context, seenExternalCodes),
    ];
  }

  static McqRowDraft _validateRow(
    McqRowDraft draft,
    McqRowValidationContext context,
    Set<String> seenExternalCodes,
  ) {
    final errors = <String>[];
    var resolvedChapterId = draft.resolvedChapterId;

    final externalCode = draft.externalCode;
    if (externalCode == null) {
      errors.add('external_code is required for idempotent re-import.');
    } else if (seenExternalCodes.contains(externalCode)) {
      errors.add('Duplicate external_code "$externalCode" within this batch.');
    } else {
      seenExternalCodes.add(externalCode);
    }

    if (draft.title.isEmpty) {
      errors.add('title is required.');
    }

    final bijoyMessage = _firstBijoyHit(draft);
    if (bijoyMessage != null) {
      errors.add(bijoyMessage);
    }

    if (draft.options.length < 2 || draft.nonEmptyOptionCount < 2) {
      errors.add('At least 2 non-empty options are required.');
    }

    if (draft.correctAns.isEmpty) {
      errors.add('correct_ans is required.');
    } else {
      final matched = draft.options.where(
        (option) => option.key == draft.correctAns,
      );
      if (matched.isEmpty) {
        errors.add(
          'correct_ans "${draft.correctAns}" does not match an option key.',
        );
      } else if (matched.first.isBlank) {
        errors.add('correct_ans "${draft.correctAns}" points to an empty option.');
      }
    }

    if (McqLevel.tryParse(draft.level) == null) {
      errors.add('level must be one of l1, l2, l3, l4.');
    }

    final chapterCode = draft.chapterCode;
    if (chapterCode != null) {
      final chapterId = context.chapterIdsByCode[chapterCode];
      if (chapterId == null) {
        errors.add(
          'chapter_code "$chapterCode" not found for the selected subject.',
        );
      } else {
        resolvedChapterId = chapterId;
      }
    } else if (context.defaultChapterId != null) {
      resolvedChapterId = context.defaultChapterId;
    } else {
      errors.add('chapter_code is required (or pick a default chapter).');
    }

    if (draft.examYearRaw.isNotEmpty) {
      final year = draft.examYear;
      if (year == null) {
        errors.add('exam_year must be a number.');
      } else if (year < 1990 || year > 2100) {
        errors.add('exam_year must be between 1990 and 2100.');
      }
    }

    return draft.copyWith(errors: errors, resolvedChapterId: resolvedChapterId);
  }

  static String? _firstBijoyHit(McqRowDraft draft) {
    final titleHit = BijoyDetector.check(draft.title);
    if (titleHit != null) return titleHit;
    for (final option in draft.options) {
      final optionHit = BijoyDetector.check(option.text);
      if (optionHit != null) return optionHit;
    }
    return BijoyDetector.check(draft.explanation);
  }
}
