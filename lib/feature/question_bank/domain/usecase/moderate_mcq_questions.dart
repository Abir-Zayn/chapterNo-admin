// Use case applying single or bulk moderation actions to MCQ questions.
import 'imports/question_bank_usecases_imports.dart';

final class ModerateMcqQuestionsUseCase {
  const ModerateMcqQuestionsUseCase(this._repository);

  final QuestionBankRepository _repository;

  Future<void> call({
    required List<String> questionIds,
    required QuestionBankModerationAction action,
  }) async {
    if (questionIds.isEmpty) return;
    if (action == QuestionBankModerationAction.deletePermanently) {
      for (final id in questionIds) {
        await _repository.deleteQuestion(id);
      }
      return;
    }
    await _repository.updateQuestionsStatus(
      questionIds: questionIds,
      action: action,
    );
  }
}
