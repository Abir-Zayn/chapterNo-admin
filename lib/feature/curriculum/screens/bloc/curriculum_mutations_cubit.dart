// Mutation and reorder handlers for CurriculumCubit.
// Isolates create, update, archive/restore, delete, and reorder operations.
import 'imports/curriculum_mutations_cubit_imports.dart';

extension CurriculumMutations on CurriculumCubit {
  Future<String?> saveEducationLevel({
    String? id,
    required String code,
    required String nameBn,
    required String nameEn,
    required int displayOrder,
  }) async {
    return runMutation(() async {
      final saved = id == null
          ? await repository.createEducationLevel(
              code: code,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
            )
          : await repository.updateEducationLevel(
              id: id,
              code: code,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
            );
      final root = await repository.fetchRoot();
      applyState(
        state.copyWith(
          levels: root.levels,
          boards: root.boards,
          selectedLevelId: saved.id,
        ),
      );
      await loadSubjectsForLevel(saved.id);
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
    return runMutation(() async {
      if (id == null) {
        await repository.createBoard(
          educationLevelId: educationLevelId,
          code: code,
          nameBn: nameBn,
          nameEn: nameEn,
          displayOrder: displayOrder,
        );
      } else {
        await repository.updateBoard(
          id: id,
          code: code,
          nameBn: nameBn,
          nameEn: nameEn,
          displayOrder: displayOrder,
        );
      }
      final root = await repository.fetchRoot();
      applyState(state.copyWith(levels: root.levels, boards: root.boards));
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
    return runMutation(() async {
      final saved = id == null
          ? await repository.createSubject(
              educationLevelId: educationLevelId,
              code: code,
              academicGroup: academicGroup,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
              nctbCode: nctbCode,
              shortNameBn: shortNameBn,
            )
          : await repository.updateSubject(
              id: id,
              code: code,
              academicGroup: academicGroup,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
              nctbCode: nctbCode,
              shortNameBn: shortNameBn,
            );
      await loadSubjectsForLevel(
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
    return runMutation(() async {
      final saved = id == null
          ? await repository.createChapter(
              subjectId: subjectId,
              chapterNumber: chapterNumber,
              code: code,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
              descriptionBn: descriptionBn,
            )
          : await repository.updateChapter(
              id: id,
              chapterNumber: chapterNumber,
              code: code,
              nameBn: nameBn,
              nameEn: nameEn,
              displayOrder: displayOrder,
              descriptionBn: descriptionBn,
            );
      await loadChaptersForSubject(subjectId, preferredChapterId: saved.id);
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
    return runMutation(() async {
      if (id == null) {
        await repository.createTopic(
          chapterId: chapterId,
          code: code,
          nameBn: nameBn,
          nameEn: nameEn,
          displayOrder: displayOrder,
          summaryBn: summaryBn,
        );
      } else {
        await repository.updateTopic(
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
        await loadChaptersForSubject(subjectId, preferredChapterId: chapterId);
      }
    });
  }

  Future<void> setArchiveState({
    required CurriculumNodeKind kind,
    required String id,
    required bool isActive,
  }) async {
    await runMutation(() async {
      switch (kind) {
        case CurriculumNodeKind.educationLevel:
          await repository.setEducationLevelArchiveState(
            id: id,
            isActive: isActive,
          );
          final root = await repository.fetchRoot();
          applyState(state.copyWith(levels: root.levels, boards: root.boards));
        case CurriculumNodeKind.board:
          await repository.setBoardArchiveState(id: id, isActive: isActive);
          final root = await repository.fetchRoot();
          applyState(state.copyWith(levels: root.levels, boards: root.boards));
        case CurriculumNodeKind.subject:
          await repository.setSubjectArchiveState(id: id, isActive: isActive);
          final levelId = state.selectedLevelId;
          if (levelId != null) await loadSubjectsForLevel(levelId);
        case CurriculumNodeKind.chapter:
          await repository.setChapterArchiveState(id: id, isActive: isActive);
          final subjectId = state.selectedSubjectId;
          if (subjectId != null) await loadChaptersForSubject(subjectId);
        case CurriculumNodeKind.topic:
          await repository.setTopicArchiveState(id: id, isActive: isActive);
          final subjectId = state.selectedSubjectId;
          if (subjectId != null) await loadChaptersForSubject(subjectId);
      }
    });
  }

  Future<void> deleteTopic(String id) async {
    await runMutation(() async {
      await repository.deleteTopic(id);
      final subjectId = state.selectedSubjectId;
      if (subjectId != null) await loadChaptersForSubject(subjectId);
    });
  }

  Future<void> reorderChapters(int oldIndex, int newIndex) async {
    final subjectId = state.selectedSubjectId;
    if (subjectId == null) return;
    final current = List<Chapter>.from(state.chapters);
    final reordered = CurriculumListHelpers.applyMove(
      current,
      oldIndex,
      newIndex,
    );
    if (reordered == null) return;

    applyState(state.copyWith(chapters: reordered, clearError: true));
    try {
      await repository.reorderNodes(
        entity: 'chapter',
        parentId: subjectId,
        orderedIds: reordered.map((c) => c.id).toList(),
      );
    } on AppFailure catch (failure) {
      applyState(
        state.copyWith(
          chapters: current,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
    }
  }

  Future<void> reorderTopics(int oldIndex, int newIndex) async {
    final chapter = state.selectedChapter;
    final subjectId = state.selectedSubjectId;
    if (chapter == null || subjectId == null) return;
    final reorderedTopics = CurriculumListHelpers.applyMove(
      chapter.topics,
      oldIndex,
      newIndex,
    );
    if (reorderedTopics == null) return;

    final previousChapters = List<Chapter>.from(state.chapters);
    final updatedChapters = CurriculumListHelpers.replaceChapterTopics(
      state.chapters,
      chapterId: chapter.id,
      topics: reorderedTopics,
    );

    applyState(state.copyWith(chapters: updatedChapters, clearError: true));
    try {
      await repository.reorderNodes(
        entity: 'topic',
        parentId: chapter.id,
        orderedIds: reorderedTopics.map((t) => t.id).toList(),
      );
    } on AppFailure catch (failure) {
      applyState(
        state.copyWith(
          chapters: previousChapters,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
    }
  }
}
