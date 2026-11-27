// Dialog and archive-confirmation action helpers for CurriculumScreen.
// Keeps modal wiring and form-to-cubit mapping out of the screen widget.
import 'imports/curriculum_dialog_actions_imports.dart';

abstract final class CurriculumDialogActions {
  static Future<void> confirmArchive(
    BuildContext context, {
    required CurriculumNodeKind kind,
    required String id,
    required String name,
    required bool currentlyActive,
  }) async {
    final confirmed = await showArchiveConfirmationDialog(
      context,
      itemName: name,
      isArchiving: currentlyActive,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<CurriculumCubit>().setArchiveState(
      kind: kind,
      id: id,
      isActive: !currentlyActive,
    );
  }

  static void openLevelDialog(
    BuildContext context,
    CurriculumState state, {
    EducationLevel? level,
  }) {
    final cubit = context.read<CurriculumCubit>();
    showCurriculumNodeDialog(
      context,
      kind: CurriculumNodeKind.educationLevel,
      isEditing: level != null,
      initialCode: level?.code ?? '',
      initialNameBn: level?.nameBn ?? '',
      initialNameEn: level?.nameEn ?? '',
      initialDisplayOrder: level?.displayOrder ?? (state.levels.length + 1),
      onSubmit: (values) => cubit.saveEducationLevel(
        id: level?.id,
        code: values.code,
        nameBn: values.nameBn,
        nameEn: values.nameEn,
        displayOrder: values.displayOrder,
      ),
    );
  }

  static void openBoardDialog(
    BuildContext context,
    CurriculumState state, {
    Board? board,
  }) {
    final levelId = state.selectedLevelId;
    if (levelId == null) return;
    final cubit = context.read<CurriculumCubit>();
    showCurriculumNodeDialog(
      context,
      kind: CurriculumNodeKind.board,
      isEditing: board != null,
      initialCode: board?.code ?? '',
      initialNameBn: board?.nameBn ?? '',
      initialNameEn: board?.nameEn ?? '',
      initialDisplayOrder: board?.displayOrder ?? (state.boards.length + 1),
      onSubmit: (values) => cubit.saveBoard(
        id: board?.id,
        educationLevelId: levelId,
        code: values.code,
        nameBn: values.nameBn,
        nameEn: values.nameEn,
        displayOrder: values.displayOrder,
      ),
    );
  }

  static void openSubjectDialog(
    BuildContext context,
    CurriculumState state, {
    Subject? subject,
  }) {
    final levelId = state.selectedLevelId;
    if (levelId == null) return;
    final cubit = context.read<CurriculumCubit>();
    showCurriculumNodeDialog(
      context,
      kind: CurriculumNodeKind.subject,
      isEditing: subject != null,
      initialCode: subject?.code ?? '',
      initialNameBn: subject?.nameBn ?? '',
      initialNameEn: subject?.nameEn ?? '',
      initialDisplayOrder: subject?.displayOrder ?? (state.subjects.length + 1),
      initialGroup: subject?.academicGroup ?? AcademicGroup.common,
      initialNctbCode: subject?.nctbCode,
      initialShortNameBn: subject?.shortNameBn,
      onSubmit: (values) => cubit.saveSubject(
        id: subject?.id,
        educationLevelId: levelId,
        code: values.code,
        academicGroup: values.academicGroup,
        nameBn: values.nameBn,
        nameEn: values.nameEn,
        displayOrder: values.displayOrder,
        nctbCode: values.nctbCode,
        shortNameBn: values.shortNameBn,
      ),
    );
  }

  static void openChapterDialog(
    BuildContext context,
    CurriculumState state, {
    Chapter? chapter,
  }) {
    final subject = state.selectedSubject;
    if (subject == null) return;
    final cubit = context.read<CurriculumCubit>();
    showCurriculumNodeDialog(
      context,
      kind: CurriculumNodeKind.chapter,
      isEditing: chapter != null,
      codePrefix: subject.code,
      initialCode: chapter?.code ?? '',
      initialNameBn: chapter?.nameBn ?? '',
      initialNameEn: chapter?.nameEn ?? '',
      initialChapterNumber:
          chapter?.chapterNumber ?? (state.chapters.length + 1),
      initialDescriptionBn: chapter?.descriptionBn,
      initialDisplayOrder: chapter?.displayOrder ?? (state.chapters.length + 1),
      onSubmit: (values) => cubit.saveChapter(
        id: chapter?.id,
        subjectId: subject.id,
        chapterNumber: values.chapterNumber ?? 1,
        code: values.code,
        nameBn: values.nameBn,
        nameEn: values.nameEn,
        displayOrder: values.displayOrder,
        descriptionBn: values.descriptionBn,
      ),
    );
  }

  static void openTopicDialog(
    BuildContext context,
    CurriculumState state, {
    Topic? topic,
  }) {
    final chapter = state.selectedChapter;
    if (chapter == null) return;
    final cubit = context.read<CurriculumCubit>();
    showCurriculumNodeDialog(
      context,
      kind: CurriculumNodeKind.topic,
      isEditing: topic != null,
      codePrefix: chapter.code,
      initialCode: topic?.code ?? '',
      initialNameBn: topic?.nameBn ?? '',
      initialNameEn: topic?.nameEn ?? '',
      initialSummaryBn: topic?.summaryBn,
      initialDisplayOrder: topic?.displayOrder ?? (chapter.topics.length + 1),
      onSubmit: (values) => cubit.saveTopic(
        id: topic?.id,
        chapterId: chapter.id,
        code: values.code,
        nameBn: values.nameBn,
        nameEn: values.nameEn,
        displayOrder: values.displayOrder,
        summaryBn: values.summaryBn,
      ),
    );
  }
}
