// Abstract contract for paginated Question Bank browsing and moderation.
import 'imports/question_bank_repository_imports.dart';

abstract interface class QuestionBankRepository {
  Future<QuestionBankPage> fetchQuestions(QuestionBankFilter filter);

  Future<void> updateQuestionsStatus({
    required List<String> questionIds,
    required QuestionBankModerationAction action,
  });

  Future<void> deleteQuestion(String questionId);
}
