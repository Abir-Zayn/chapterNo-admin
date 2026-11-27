// Responsive 3-column master-detail syllabus view (Subjects, Chapters, Topics).
// Uses Row on desktop (>=1000dp) and FButtons + IndexedStack on mobile.
import 'imports/curriculum_syllabus_view_imports.dart';

class CurriculumSyllabusView extends StatefulWidget {
  const CurriculumSyllabusView({
    super.key,
    required this.state,
    required this.canEditSyllabus,
    required this.canDeleteTopic,
  });

  final CurriculumState state;
  final bool canEditSyllabus;
  final bool canDeleteTopic;

  @override
  State<CurriculumSyllabusView> createState() => _CurriculumSyllabusViewState();
}

class _CurriculumSyllabusViewState extends State<CurriculumSyllabusView> {
  int _mobilePaneIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    final cubit = context.read<CurriculumCubit>();
    final state = widget.state;

    final subjectPane = SubjectListPane(
      subjects: state.visibleSubjects,
      selectedSubjectId: state.selectedSubjectId,
      selectedGroup: state.selectedGroup,
      isLoading: state.isLoadingSubjects,
      canEdit: widget.canEditSyllabus && state.selectedLevelId != null,
      onSelectGroup: cubit.setGroupFilter,
      onSelectSubject: (id) {
        cubit.selectSubject(id);
        if (!isDesktop) setState(() => _mobilePaneIndex = 1);
      },
      onAddSubject: () =>
          CurriculumDialogActions.openSubjectDialog(context, state),
      onEditSubject: (subject) => CurriculumDialogActions.openSubjectDialog(
        context,
        state,
        subject: subject,
      ),
      onToggleArchive: (subject) => CurriculumDialogActions.confirmArchive(
        context,
        kind: CurriculumNodeKind.subject,
        id: subject.id,
        name: subject.nameEn,
        currentlyActive: subject.isActive,
      ),
    );

    final chapterPane = ChapterListPane(
      chapters: state.visibleChapters,
      selectedChapterId: state.selectedChapterId,
      hasSelectedSubject: state.selectedSubjectId != null,
      isLoading: state.isLoadingChapters,
      canEdit: widget.canEditSyllabus,
      onSelectChapter: (id) {
        cubit.selectChapter(id);
        if (!isDesktop) setState(() => _mobilePaneIndex = 2);
      },
      onAddChapter: () =>
          CurriculumDialogActions.openChapterDialog(context, state),
      onEditChapter: (chapter) => CurriculumDialogActions.openChapterDialog(
        context,
        state,
        chapter: chapter,
      ),
      onToggleArchive: (chapter) => CurriculumDialogActions.confirmArchive(
        context,
        kind: CurriculumNodeKind.chapter,
        id: chapter.id,
        name: chapter.nameEn,
        currentlyActive: chapter.isActive,
      ),
      onReorder: cubit.reorderChapters,
    );

    final topicPane = TopicListPane(
      topics: state.visibleTopics,
      hasSelectedChapter: state.selectedChapterId != null,
      canEdit: widget.canEditSyllabus,
      canDelete: widget.canDeleteTopic,
      onAddTopic: () => CurriculumDialogActions.openTopicDialog(context, state),
      onEditTopic: (topic) =>
          CurriculumDialogActions.openTopicDialog(context, state, topic: topic),
      onToggleArchive: (topic) => CurriculumDialogActions.confirmArchive(
        context,
        kind: CurriculumNodeKind.topic,
        id: topic.id,
        name: topic.nameEn,
        currentlyActive: topic.isActive,
      ),
      onDeleteTopic: (topic) => cubit.deleteTopic(topic.id),
      onReorder: cubit.reorderTopics,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 4, child: subjectPane),
          const SizedBox(width: 12),
          Expanded(flex: 4, child: chapterPane),
          const SizedBox(width: 12),
          Expanded(flex: 4, child: topicPane),
        ],
      );
    }

    return Column(
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            FButton(
              variant: _mobilePaneIndex == 0 ? .primary : .outline,
              size: .sm,
              mainAxisSize: .min,
              onPress: () => setState(() => _mobilePaneIndex = 0),
              child: const Text('Subjects'),
            ),
            FButton(
              variant: _mobilePaneIndex == 1 ? .primary : .outline,
              size: .sm,
              mainAxisSize: .min,
              onPress: () => setState(() => _mobilePaneIndex = 1),
              child: const Text('Chapters'),
            ),
            FButton(
              variant: _mobilePaneIndex == 2 ? .primary : .outline,
              size: .sm,
              mainAxisSize: .min,
              onPress: () => setState(() => _mobilePaneIndex = 2),
              child: const Text('Topics'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: IndexedStack(
            index: _mobilePaneIndex,
            children: [subjectPane, chapterPane, topicPane],
          ),
        ),
      ],
    );
  }
}
