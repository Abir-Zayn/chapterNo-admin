// Cubit orchestrating Question Bank browsing, debounced search, multi-axis
// filters, pagination, bulk selection, and role-safe status moderation.
import 'imports/question_bank_cubit_imports.dart';

class QuestionBankCubit extends Cubit<QuestionBankState> {
  QuestionBankCubit(this._repository, this._curriculumRepository)
    : super(const QuestionBankState());

  final QuestionBankRepository _repository;
  final CurriculumRepository _curriculumRepository;

  late final FetchQuestionBankPageUseCase _fetchPage =
      FetchQuestionBankPageUseCase(_repository);
  late final ModerateMcqQuestionsUseCase _moderate =
      ModerateMcqQuestionsUseCase(_repository);

  Timer? _searchDebounce;

  Future<void> initialize() async {
    emit(
      state.copyWith(
        status: QuestionBankLoadStatus.loading,
        clearError: true,
        clearFeedback: true,
      ),
    );
    try {
      final root = await _curriculumRepository.fetchRoot();
      final levelId = CurriculumListHelpers.pickPreferredId(
        state.selectedLevelId,
        root.levels
            .where((level) => !level.isArchived)
            .map((level) => level.id)
            .toList(),
      );
      List<Subject> subjects = const [];
      if (levelId != null) {
        subjects = await _curriculumRepository.fetchSubjects(
          levelId: levelId,
          isActive: true,
        );
      }
      emit(
        state.copyWith(
          status: QuestionBankLoadStatus.ready,
          levels: root.levels,
          boards: root.boards,
          subjects: subjects,
          selectedLevelId: levelId,
          clearSelectedLevel: levelId == null,
        ),
      );
      await fetchCurrentPage();
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: QuestionBankLoadStatus.error,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
    }
  }

  Future<void> fetchCurrentPage() async {
    emit(
      state.copyWith(
        isFetchingPage: true,
        clearError: true,
      ),
    );
    try {
      final result = await _fetchPage(state.filter);
      final visibleIds = result.items.map((item) => item.id).toSet();
      final retainedSelection = state.selectedIds.intersection(visibleIds);
      emit(
        state.copyWith(
          status: QuestionBankLoadStatus.ready,
          items: result.items,
          totalCount: result.totalCount,
          selectedIds: retainedSelection,
          isFetchingPage: false,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          isFetchingPage: false,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
    }
  }

  void updateSearchQuery(String query) {
    _searchDebounce?.cancel();
    final updated = state.filter.copyWith(searchQuery: query, page: 1);
    emit(state.copyWith(filter: updated, selectedIds: const {}));
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      fetchCurrentPage();
    });
  }

  Future<void> selectLevel(String? levelId) async {
    if (levelId == state.selectedLevelId) return;
    emit(
      state.copyWith(
        selectedLevelId: levelId,
        clearSelectedLevel: levelId == null,
        subjects: const [],
        chapters: const [],
        selectedIds: const {},
        filter: state.filter.copyWith(
          clearSubject: true,
          clearChapter: true,
          clearTopic: true,
          clearBoard: true,
          page: 1,
        ),
      ),
    );
    if (levelId != null) {
      try {
        final subjects = await _curriculumRepository.fetchSubjects(
          levelId: levelId,
          isActive: true,
        );
        emit(state.copyWith(subjects: subjects));
      } on AppFailure catch (failure) {
        emit(
          state.copyWith(
            errorMessage: failure.message,
            errorStatusCode: failure.statusCode,
          ),
        );
      }
    }
    await fetchCurrentPage();
  }

  Future<void> selectSubject(int? subjectId) async {
    if (subjectId == state.filter.subjectId) return;
    emit(
      state.copyWith(
        chapters: const [],
        isLoadingChapters: subjectId != null,
        selectedIds: const {},
        filter: state.filter.copyWith(
          subjectId: subjectId,
          clearSubject: subjectId == null,
          clearChapter: true,
          clearTopic: true,
          page: 1,
        ),
      ),
    );
    if (subjectId != null) {
      try {
        final chapters = await _curriculumRepository.fetchChaptersWithTopics(
          subjectId: subjectId.toString(),
        );
        emit(state.copyWith(chapters: chapters, isLoadingChapters: false));
      } on AppFailure catch (failure) {
        emit(
          state.copyWith(
            isLoadingChapters: false,
            errorMessage: failure.message,
            errorStatusCode: failure.statusCode,
          ),
        );
      }
    }
    await fetchCurrentPage();
  }

  Future<void> selectChapter(int? chapterId) async {
    if (chapterId == state.filter.chapterId) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(
          chapterId: chapterId,
          clearChapter: chapterId == null,
          clearTopic: true,
          page: 1,
        ),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> selectTopic(int? topicId) async {
    if (topicId == state.filter.topicId) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(
          topicId: topicId,
          clearTopic: topicId == null,
          page: 1,
        ),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> selectBoard(String? boardId) async {
    if (boardId == state.filter.boardId) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(
          boardId: boardId,
          clearBoard: boardId == null,
          page: 1,
        ),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> selectStatus(McqStatus? status) async {
    if (status == state.filter.status) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(
          status: status,
          clearStatus: status == null,
          page: 1,
        ),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> selectSourceType(McqSourceType? sourceType) async {
    if (sourceType == state.filter.sourceType) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(
          sourceType: sourceType,
          clearSourceType: sourceType == null,
          page: 1,
        ),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> selectDifficulty(McqDifficulty? difficulty) async {
    if (difficulty == state.filter.difficulty) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(
          difficulty: difficulty,
          clearDifficulty: difficulty == null,
          page: 1,
        ),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> selectRightsStatus(McqRightsStatus? rightsStatus) async {
    if (rightsStatus == state.filter.rightsStatus) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(
          rightsStatus: rightsStatus,
          clearRightsStatus: rightsStatus == null,
          page: 1,
        ),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> setExamYear(int? year) async {
    if (year == state.filter.examYear) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(
          examYear: year,
          clearExamYear: year == null,
          page: 1,
        ),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> clearAllFilters() async {
    _searchDebounce?.cancel();
    emit(
      state.copyWith(
        chapters: const [],
        selectedIds: const {},
        filter: const QuestionBankFilter(),
      ),
    );
    await fetchCurrentPage();
  }

  Future<void> goToPage(int page) async {
    final target = page.clamp(1, state.totalPages);
    if (target == state.filter.page) return;
    emit(
      state.copyWith(
        selectedIds: const {},
        filter: state.filter.copyWith(page: target),
      ),
    );
    await fetchCurrentPage();
  }

  void toggleSelection(String id) {
    final updated = Set<String>.from(state.selectedIds);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    emit(state.copyWith(selectedIds: updated));
  }

  void toggleSelectAll(List<String> eligibleIds) {
    final allSelected =
        eligibleIds.isNotEmpty &&
        eligibleIds.every((id) => state.selectedIds.contains(id));
    if (allSelected) {
      emit(state.copyWith(selectedIds: const {}));
    } else {
      emit(state.copyWith(selectedIds: eligibleIds.toSet()));
    }
  }

  void clearSelection() {
    emit(state.copyWith(selectedIds: const {}));
  }

  Future<bool> applyModeration({
    required List<String> questionIds,
    required QuestionBankModerationAction action,
  }) async {
    if (questionIds.isEmpty || state.isModerating) return false;
    emit(
      state.copyWith(
        isModerating: true,
        clearError: true,
        clearFeedback: true,
      ),
    );
    try {
      await _moderate(questionIds: questionIds, action: action);
      final count = questionIds.length;
      final label = _actionFeedbackLabel(action, count);
      emit(
        state.copyWith(
          isModerating: false,
          selectedIds: const {},
          feedbackMessage: label,
        ),
      );
      await fetchCurrentPage();
      return true;
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          isModerating: false,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
      return false;
    }
  }

  void clearFeedback() {
    emit(state.copyWith(clearFeedback: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  String _actionFeedbackLabel(QuestionBankModerationAction action, int count) {
    final noun = count == 1 ? 'question' : '$count questions';
    switch (action) {
      case QuestionBankModerationAction.approveAndPublish:
        return 'Published & verified $noun.';
      case QuestionBankModerationAction.submitForReview:
        return 'Submitted $noun for review.';
      case QuestionBankModerationAction.sendToDraft:
        return 'Moved $noun back to draft.';
      case QuestionBankModerationAction.archive:
        return 'Archived $noun.';
      case QuestionBankModerationAction.restore:
        return 'Restored $noun to draft.';
      case QuestionBankModerationAction.deletePermanently:
        return 'Deleted $noun permanently.';
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
