// Cubit orchestrating Curriculum Catalogue loading, selection, and filtering.
// Mutations and reorders are split into curriculum_mutations_cubit.dart.
import 'imports/curriculum_cubit_imports.dart';

export 'curriculum_mutations_cubit.dart';

class CurriculumCubit extends Cubit<CurriculumState> {
  CurriculumCubit(this.repository) : super(const CurriculumState());

  final CurriculumRepository repository;

  void applyState(CurriculumState next) => emit(next);

  Future<void> loadInitial() async {
    emit(state.copyWith(status: CurriculumStatus.loading, clearError: true));
    try {
      final root = await repository.fetchRoot();
      final levelId = CurriculumListHelpers.pickPreferredId(
        state.selectedLevelId,
        root.levels.map((e) => e.id).toList(),
      );
      emit(
        state.copyWith(
          status: CurriculumStatus.ready,
          levels: root.levels,
          boards: root.boards,
          selectedLevelId: levelId,
          clearSelectedLevel: levelId == null,
        ),
      );
      if (levelId != null) {
        await loadSubjectsForLevel(levelId);
      } else {
        emit(
          state.copyWith(
            subjects: const [],
            chapters: const [],
            clearSelectedSubject: true,
            clearSelectedChapter: true,
          ),
        );
      }
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: CurriculumStatus.error,
          errorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> selectLevel(String levelId) async {
    if (levelId == state.selectedLevelId) return;
    emit(
      state.copyWith(
        selectedLevelId: levelId,
        clearSelectedSubject: true,
        clearSelectedChapter: true,
        subjects: const [],
        chapters: const [],
        clearError: true,
      ),
    );
    await loadSubjectsForLevel(levelId);
  }

  Future<void> selectSubject(String subjectId) async {
    if (subjectId == state.selectedSubjectId) return;
    emit(
      state.copyWith(
        selectedSubjectId: subjectId,
        clearSelectedChapter: true,
        chapters: const [],
        clearError: true,
      ),
    );
    await loadChaptersForSubject(subjectId);
  }

  void selectChapter(String chapterId) {
    emit(state.copyWith(selectedChapterId: chapterId, clearError: true));
  }

  void setTab(CurriculumTab tab) {
    emit(state.copyWith(activeTab: tab, clearError: true));
  }

  void setGroupFilter(AcademicGroup? group) {
    emit(
      state.copyWith(selectedGroup: group, clearSelectedGroup: group == null),
    );
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> toggleShowArchived(bool showArchived) async {
    emit(state.copyWith(showArchived: showArchived, clearError: true));
    final levelId = state.selectedLevelId;
    if (levelId != null) {
      await loadSubjectsForLevel(levelId);
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> loadSubjectsForLevel(
    String levelId, {
    String? preferredSubjectId,
  }) async {
    emit(state.copyWith(isLoadingSubjects: true, clearError: true));
    try {
      final subjects = await repository.fetchSubjects(
        levelId: levelId,
        isActive: state.showArchived ? null : true,
      );
      final subjectId = CurriculumListHelpers.pickPreferredId(
        preferredSubjectId ?? state.selectedSubjectId,
        subjects.map((s) => s.id).toList(),
      );
      emit(
        state.copyWith(
          isLoadingSubjects: false,
          subjects: subjects,
          selectedSubjectId: subjectId,
          clearSelectedSubject: subjectId == null,
        ),
      );
      if (subjectId != null) {
        await loadChaptersForSubject(subjectId);
      } else {
        emit(state.copyWith(chapters: const [], clearSelectedChapter: true));
      }
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(isLoadingSubjects: false, errorMessage: failure.message),
      );
    }
  }

  Future<void> loadChaptersForSubject(
    String subjectId, {
    String? preferredChapterId,
  }) async {
    emit(state.copyWith(isLoadingChapters: true, clearError: true));
    try {
      final chapters = await repository.fetchChaptersWithTopics(
        subjectId: subjectId,
      );
      final chapterId = CurriculumListHelpers.pickPreferredId(
        preferredChapterId ?? state.selectedChapterId,
        chapters.map((c) => c.id).toList(),
      );
      emit(
        state.copyWith(
          isLoadingChapters: false,
          chapters: chapters,
          selectedChapterId: chapterId,
          clearSelectedChapter: chapterId == null,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(isLoadingChapters: false, errorMessage: failure.message),
      );
    }
  }

  Future<String?> runMutation(Future<void> Function() action) async {
    emit(state.copyWith(isMutating: true, clearError: true));
    try {
      await action();
      emit(state.copyWith(isMutating: false));
      return null;
    } on AppFailure catch (failure) {
      emit(state.copyWith(isMutating: false, errorMessage: failure.message));
      return failure.message;
    }
  }
}
