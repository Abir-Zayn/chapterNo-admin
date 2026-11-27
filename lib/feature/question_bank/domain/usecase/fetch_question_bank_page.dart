// Use case fetching a paginated, multi-axis filtered Question Bank page.
import 'imports/question_bank_usecases_imports.dart';

final class FetchQuestionBankPageUseCase {
  const FetchQuestionBankPageUseCase(this._repository);

  final QuestionBankRepository _repository;

  Future<QuestionBankPage> call(QuestionBankFilter filter) {
    return _repository.fetchQuestions(filter);
  }
}
