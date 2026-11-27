// Curriculum Catalogue screen with desktop 3-column master-detail layout
// and mobile-friendly pane switcher, search, archive filter, and role gating.
import 'curriculum_screen_imports.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final _searchController = TextEditingController();
  int _mobilePaneIndex = 0;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CurriculumCubit>();
    if (cubit.state.status == CurriculumStatus.initial) {
      cubit.loadInitial();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select(
      (AuthCubit cubit) => cubit.state.adminUser?.role ?? AdminRole.reviewer,
    );
    final isReviewer = role == AdminRole.reviewer;
    final canEditSyllabus =
        role == AdminRole.superAdmin || role == AdminRole.editor;
    final canMutateLevelsAndBoards = role == AdminRole.superAdmin;

    return BlocBuilder<CurriculumCubit, CurriculumState>(
      builder: (context, state) {
        if (state.status == CurriculumStatus.loading ||
            state.status == CurriculumStatus.initial) {
          return const AppLoadingView(
            message: 'Loading Curriculum Catalogue...',
          );
        }

        if (state.status == CurriculumStatus.error && state.levels.isEmpty) {
          return AppEmptyView(
            title: 'Failed to load curriculum',
            subtitle: state.errorMessage ?? 'Unable to reach GraphQL API.',
            icon: PhosphorIconsRegular.warningCircle,
            action: FilledButton.icon(
              onPressed: () => context.read<CurriculumCubit>().loadInitial(),
              icon: const Icon(PhosphorIconsRegular.arrowClockwise, size: 16),
              label: const Text('Retry'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopControlsBar(
              state: state,
              searchController: _searchController,
              isReviewer: isReviewer,
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              AppErrorBanner(
                message: state.errorMessage!,
                onDismiss: () => context.read<CurriculumCubit>().clearError(),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: state.activeTab == CurriculumTab.boardsAndLevels
                  ? BoardsLevelsTab(
                      levels: state.visibleLevels,
                      boards: state.visibleBoards,
                      selectedLevelId: state.selectedLevelId,
                      canMutateLevelsAndBoards: canMutateLevelsAndBoards,
                      onSelectLevel: (id) =>
                          context.read<CurriculumCubit>().selectLevel(id),
                      onAddLevel: () => _openLevelDialog(context, state),
                      onEditLevel: (level) =>
                          _openLevelDialog(context, state, level: level),
                      onToggleLevelArchive: (level) => _confirmArchive(
                        context,
                        kind: CurriculumNodeKind.educationLevel,
                        id: level.id,
                        name: level.nameEn,
                        currentlyActive: level.isActive,
                      ),
                      onAddBoard: () => _openBoardDialog(context, state),
                      onEditBoard: (board) =>
                          _openBoardDialog(context, state, board: board),
                      onToggleBoardArchive: (board) => _confirmArchive(
                        context,
                        kind: CurriculumNodeKind.board,
                        id: board.id,
                        name: board.nameEn,
                        currentlyActive: board.isActive,
                      ),
                    )
                  : _buildSyllabusView(
                      context,
                      state: state,
                      canEditSyllabus: canEditSyllabus,
                      canDeleteTopic: canMutateLevelsAndBoards,
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSyllabusView(
    BuildContext context, {
    required CurriculumState state,
    required bool canEditSyllabus,
    required bool canDeleteTopic,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    final cubit = context.read<CurriculumCubit>();

    final subjectPane = SubjectListPane(
      subjects: state.visibleSubjects,
      selectedSubjectId: state.selectedSubjectId,
      selectedGroup: state.selectedGroup,
      isLoading: state.isLoadingSubjects,
      canEdit: canEditSyllabus && state.selectedLevelId != null,
      onSelectGroup: cubit.setGroupFilter,
      onSelectSubject: (id) {
        cubit.selectSubject(id);
        if (!isDesktop) setState(() => _mobilePaneIndex = 1);
      },
      onAddSubject: () => _openSubjectDialog(context, state),
      onEditSubject: (subject) =>
          _openSubjectDialog(context, state, subject: subject),
      onToggleArchive: (subject) => _confirmArchive(
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
      canEdit: canEditSyllabus,
      onSelectChapter: (id) {
        cubit.selectChapter(id);
        if (!isDesktop) setState(() => _mobilePaneIndex = 2);
      },
      onAddChapter: () => _openChapterDialog(context, state),
      onEditChapter: (chapter) =>
          _openChapterDialog(context, state, chapter: chapter),
      onToggleArchive: (chapter) => _confirmArchive(
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
      canEdit: canEditSyllabus,
      canDelete: canDeleteTopic,
      onAddTopic: () => _openTopicDialog(context, state),
      onEditTopic: (topic) => _openTopicDialog(context, state, topic: topic),
      onToggleArchive: (topic) => _confirmArchive(
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
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('Subjects')),
            ButtonSegment(value: 1, label: Text('Chapters')),
            ButtonSegment(value: 2, label: Text('Topics')),
          ],
          selected: {_mobilePaneIndex},
          onSelectionChanged: (values) {
            setState(() => _mobilePaneIndex = values.first);
          },
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

  Future<void> _confirmArchive(
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

  void _openLevelDialog(
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

  void _openBoardDialog(
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

  void _openSubjectDialog(
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

  void _openChapterDialog(
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

  void _openTopicDialog(
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

class _TopControlsBar extends StatelessWidget {
  const _TopControlsBar({
    required this.state,
    required this.searchController,
    required this.isReviewer,
  });

  final CurriculumState state;
  final TextEditingController searchController;
  final bool isReviewer;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CurriculumCubit>();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Curriculum Catalogue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              if (isReviewer) StatusBadge.neutral('Read-only (Reviewer)'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (state.levels.isNotEmpty)
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<String>(
                    initialValue: state.selectedLevelId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Education Level',
                    ),
                    items: state.levels
                        .map(
                          (level) => DropdownMenuItem(
                            value: level.id,
                            child: Text(
                              '${level.nameEn} (${level.nameBn})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) cubit.selectLevel(value);
                    },
                  ),
                ),
              SizedBox(
                width: 240,
                child: TextField(
                  controller: searchController,
                  onChanged: cubit.setSearchQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search Bangla, English, or code...',
                    prefixIcon: Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                      size: 16,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: state.showArchived,
                    onChanged: cubit.toggleShowArchived,
                  ),
                  const SizedBox(width: 4),
                  const Text('Show Archived', style: TextStyle(fontSize: 13)),
                ],
              ),
              SegmentedButton<CurriculumTab>(
                segments: const [
                  ButtonSegment(
                    value: CurriculumTab.syllabus,
                    label: Text('Subjects & Syllabus'),
                  ),
                  ButtonSegment(
                    value: CurriculumTab.boardsAndLevels,
                    label: Text('Boards & Levels'),
                  ),
                ],
                selected: {state.activeTab},
                onSelectionChanged: (values) => cubit.setTab(values.first),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
