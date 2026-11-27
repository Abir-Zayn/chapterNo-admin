// Cubit orchestrating Curriculum Catalogue browsing, filtering, and mutations.
// Handles cascading Level -> Subject -> Chapter -> Topic state and reorders.
import 'curriculum_cubit_imports.dart';

class CurriculumCubit extends Cubit<CurriculumState> {
  CurriculumCubit(this._repository) : super(const CurriculumState());

  final CurriculumRepository _repository;

  Future<void> loadInitial() async {
    emit(state.copyWith(status: CurriculumStatus.loading, clearError: true));
    try {
      final root = await _repository.fetchRoot();
      final levelId = _pickPreferredId(
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
        await _loadSubjectsForLevel(levelId);
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
    await _loadSubjectsForLevel(levelId);
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
    await _loadChaptersForSubject(subjectId);
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
      await _loadSubjectsForLevel(levelId);
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<String?> saveEducationLevel({
    String? id,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  }) async {
    return _runMutation(() async {
      final saved = id == null
          ? await _repository.createEducationLevel(
              code: code,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
            )
          : await _repository.updateEducationLevel(
              id: id,
              code: code,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
            );
      final root = await _repository.fetchRoot();
      emit(
        state.copyWith(
          levels: root.levels,
          boards: root.boards,
          selectedLevelId: saved.id,
        ),
      );
      await _loadSubjectsForLevel(saved.id);
    });
  }

  Future<String?> saveBoard({
    String? id,
    required String educationLevelId,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  }) async {
    return _runMutation(() async {
      if (id == null) {
        await _repository.createBoard(
          educationLevelId: educationLevelId,
          code: code,
          nameBn: nameBn,
          nameEn: nameEn,
          displayOrder: displayOrder,
        );
      } else {
        await _repository.updateBoard(
          id: id,
          code: code,
          nameBn: nameBn,
          nameEn: nameEn,
          displayOrder: displayOrder,
        );
      }
      final root = await _repository.fetchRoot();
      emit(state.copyWith(levels: root.levels, boards: root.boards));
    });
  }

  Future<String?> saveSubject({
    String? id,
    required String educationLevelId,
    required String code,
    required AcademicGroup academicGroup,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? nctbCode,
    String? shortNameBn,
  }) async {
    return _runMutation(() async {
      final saved = id == null
          ? await _repository.createSubject(
              educationLevelId: educationLevelId,
              code: code,
              academicGroup: academicGroup,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
              nctbCode: nctbCode,
              shortNameBn: shortNameBn,
            )
          : await _repository.updateSubject(
              id: id,
              code: code,
              academicGroup: academicGroup,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
              nctbCode: nctbCode,
              shortNameBn: shortNameBn,
            );
      await _loadSubjectsForLevel(
        educationLevelId,
        preferredSubjectId: saved.id,
      );
    });
  }

  Future<String?> saveChapter({
    String? id,
    required String subjectId,
    required int chapterNumber,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? descriptionBn,
  }) async {
    return _runMutation(() async {
      final saved = id == null
          ? await _repository.createChapter(
              subjectId: subjectId,
              chapterNumber: chapterNumber,
              code: code,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
              descriptionBn: descriptionBn,
            )
          : await _repository.updateChapter(
              id: id,
              chapterNumber: chapterNumber,
              code: code,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
              descriptionBn: descriptionBn,
            );
      await _loadChaptersForSubject(subjectId, preferredChapterId: saved.id);
    });
  }

  Future<String?> saveTopic({
    String? id,
    required String chapterId,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
    String? summaryBn,
  }) async {
    return _runMutation(() async {
      if (id == null) {
        await _repository.createTopic(
          chapterId: chapterId,
          code: code,
          nameBn: nameBn,
          nameEn: nameEn,
          displayOrder: displayOrder,
          summaryBn: summaryBn,
        );
      } else {
        await _repository.updateTopic(
          id: id,
          code: code,
          nameBn: nameBn,
          nameEn: nameEn,
          displayOrder: displayOrder,
          summaryBn: summaryBn,
        );
      }
      final subjectId = state.selectedSubjectId;
      if (subjectId != null) {
        await _loadChaptersForSubject(subjectId, preferredChapterId: chapterId);
      }
    });
  }

  Future<void> setArchiveState({
    required CurriculumNodeKind kind,
    required String id,
    required bool isActive,
  }) async {
    await _runMutation(() async {
      switch (kind) {
        case CurriculumNodeKind.educationLevel:
          await _repository.setEducationLevelArchiveState(
            id: id,
            isActive: isActive,
          );
          final root = await _repository.fetchRoot();
          emit(state.copyWith(levels: root.levels, boards: root.boards));
        case CurriculumNodeKind.board:
          await _repository.setBoardArchiveState(id: id, isActive: isActive);
          final root = await _repository.fetchRoot();
          emit(state.copyWith(levels: root.levels, boards: root.boards));
        case CurriculumNodeKind.subject:
          await _repository.setSubjectArchiveState(id: id, isActive: isActive);
          final levelId = state.selectedLevelId;
          if (levelId != null) await _loadSubjectsForLevel(levelId);
        case CurriculumNodeKind.chapter:
          await _repository.setChapterArchiveState(id: id, isActive: isActive);
          final subjectId = state.selectedSubjectId;
          if (subjectId != null) await _loadChaptersForSubject(subjectId);
        case CurriculumNodeKind.topic:
          await _repository.setTopicArchiveState(id: id, isActive: isActive);
          final subjectId = state.selectedSubjectId;
          if (subjectId != null) await _loadChaptersForSubject(subjectId);
      }
    });
  }

  Future<void> deleteTopic(String id) async {
    await _runMutation(() async {
      await _repository.deleteTopic(id);
      final subjectId = state.selectedSubjectId;
      if (subjectId != null) await _loadChaptersForSubject(subjectId);
    });
  }

  Future<void> reorderChapters(int oldIndex, int newIndex) async {
    final subjectId = state.selectedSubjectId;
    if (subjectId == null) return;
    final current = List<Chapter>.from(state.chapters);
    final reordered = _applyMove(current, oldIndex, newIndex);
    if (reordered == null) return;

    emit(state.copyWith(chapters: reordered, clearError: true));
    try {
      await _repository.reorderNodes(
        entity: 'chapter',
        parentId: subjectId,
        orderedIds: reordered.map((c) => c.id).toList(),
      );
    } on AppFailure catch (failure) {
      emit(state.copyWith(chapters: current, errorMessage: failure.message));
    }
  }

  Future<void> reorderTopics(int oldIndex, int newIndex) async {
    final chapter = state.selectedChapter;
    final subjectId = state.selectedSubjectId;
    if (chapter == null || subjectId == null) return;
    final currentTopics = List<Topic>.from(chapter.topics);
    final reorderedTopics = _applyMove(currentTopics, oldIndex, newIndex);
    if (reorderedTopics == null) return;

    final previousChapters = List<Chapter>.from(state.chapters);
    final updatedChapters = state.chapters.map((c) {
      if (c.id != chapter.id) return c;
      return Chapter(
        id: c.id,
        subjectId: c.subjectId,
        chapterNumber: c.chapterNumber,
        code: c.code,
        nameBn: c.nameBn,
        nameEn: c.nameEn,
        descriptionBn: c.descriptionBn,
        displayOrder: c.displayOrder,
        isActive: c.isActive,
        archivedAt: c.archivedAt,
        topics: reorderedTopics,
      );
    }).toList();

    emit(state.copyWith(chapters: updatedChapters, clearError: true));
    try {
      await _repository.reorderNodes(
        entity: 'topic',
        parentId: chapter.id,
        orderedIds: reorderedTopics.map((t) => t.id).toList(),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          chapters: previousChapters,
          errorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> _loadSubjectsForLevel(
    String levelId, {
    String? preferredSubjectId,
  }) async {
    emit(state.copyWith(isLoadingSubjects: true, clearError: true));
    try {
      final subjects = await _repository.fetchSubjects(
        levelId: levelId,
        isActive: state.showArchived ? null : true,
      );
      final subjectId = _pickPreferredId(
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
        await _loadChaptersForSubject(subjectId);
      } else {
        emit(state.copyWith(chapters: const [], clearSelectedChapter: true));
      }
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(isLoadingSubjects: false, errorMessage: failure.message),
      );
    }
  }

  Future<void> _loadChaptersForSubject(
    String subjectId, {
    String? preferredChapterId,
  }) async {
    emit(state.copyWith(isLoadingChapters: true, clearError: true));
    try {
      final chapters = await _repository.fetchChaptersWithTopics(
        subjectId: subjectId,
      );
      final chapterId = _pickPreferredId(
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

  Future<String?> _runMutation(Future<void> Function() action) async {
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

  String? _pickPreferredId(String? preferred, List<String> available) {
    if (available.isEmpty) return null;
    if (preferred != null && available.contains(preferred)) return preferred;
    return available.first;
  }

  List<T>? _applyMove<T>(List<T> items, int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= items.length) return null;
    if (newIndex < 0 || newIndex >= items.length || newIndex == oldIndex) {
      return null;
    }
    final copy = List<T>.from(items);
    final moved = copy.removeAt(oldIndex);
    copy.insert(newIndex, moved);
    return copy;
  }
}
