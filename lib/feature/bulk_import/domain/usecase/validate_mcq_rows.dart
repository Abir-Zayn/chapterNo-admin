// Use case: validate parsed MCQ rows against the selected curriculum context.
// Thin orchestration wrapper keeping the Cubit free of validator details.
import 'imports/validate_mcq_rows_imports.dart';

class ValidateMcqRowsUseCase {
  const ValidateMcqRowsUseCase();

  List<McqRowDraft> call(
    List<Map<String, dynamic>> parsedRows,
    McqRowValidationContext context,
  ) {
    final drafts = [
      for (final (index, row) in parsedRows.indexed)
        McqRowDraft.fromParsedRow(index + 1, row),
    ];
    return McqRowValidator.validate(drafts, context);
  }
}
