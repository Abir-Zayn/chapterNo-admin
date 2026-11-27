// Chapters and Topics detail panes with drag-to-reorder and role-gated CRUD.
// Supports ReorderableListView handles, archive/restore, and safe topic delete.
import 'imports/chapter_topic_pane_imports.dart';

class ChapterListPane extends StatelessWidget {
  const ChapterListPane({
    super.key,
    required this.chapters,
    required this.selectedChapterId,
    required this.hasSelectedSubject,
    required this.isLoading,
    required this.canEdit,
    required this.onSelectChapter,
    required this.onAddChapter,
    required this.onEditChapter,
    required this.onToggleArchive,
    required this.onReorder,
  });

  final List<Chapter> chapters;
  final String? selectedChapterId;
  final bool hasSelectedSubject;
  final bool isLoading;
  final bool canEdit;
  final ValueChanged<String> onSelectChapter;
  final VoidCallback onAddChapter;
  final ValueChanged<Chapter> onEditChapter;
  final ValueChanged<Chapter> onToggleArchive;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Chapters',
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canEdit && hasSelectedSubject)
                  FButton(
                    variant: .outline,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: onAddChapter,
                    prefix: const Icon(FPhosphorIcons.plus, size: 15),
                    child: const Text('Add Chapter'),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: !hasSelectedSubject
                ? const AppEmptyView(
                    title: 'Select a subject',
                    subtitle: 'Choose a subject to view and manage chapters.',
                    icon: FPhosphorIcons.bookOpen,
                  )
                : isLoading
                ? const AppLoadingView(message: 'Loading chapters...')
                : chapters.isEmpty
                ? const AppEmptyView(
                    title: 'No chapters yet',
                    subtitle:
                        'Add the first textbook chapter for this subject.',
                    icon: FPhosphorIcons.listNumbers,
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(10),
                    buildDefaultDragHandles: false,
                    itemCount: chapters.length,
                    onReorderItem: onReorder,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      final isSelected = chapter.id == selectedChapterId;
                      return Padding(
                        key: ValueKey(chapter.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ChapterTile(
                          index: index,
                          chapter: chapter,
                          isSelected: isSelected,
                          canEdit: canEdit,
                          onTap: () => onSelectChapter(chapter.id),
                          onEdit: () => onEditChapter(chapter),
                          onToggleArchive: () => onToggleArchive(chapter),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.index,
    required this.chapter,
    required this.isSelected,
    required this.canEdit,
    required this.onTap,
    required this.onEdit,
    required this.onToggleArchive,
  });

  final int index;
  final Chapter chapter;
  final bool isSelected;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return FTappable(
      onPress: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? colors.secondary : colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canEdit)
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 2),
                  child: Icon(
                    FPhosphorIcons.dotsSixVertical,
                    size: 18,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge.neutral('অধ্যায় ${chapter.chapterNumber}'),
                      const SizedBox(width: 6),
                      if (chapter.isArchived) StatusBadge.neutral('Archived'),
                      const Spacer(),
                      Text(
                        '${chapter.topics.length} topics',
                        style: typography.body.xs.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chapter.nameBn,
                    style: AppTypography.bangla(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.primary : colors.foreground,
                    ),
                  ),
                  Text(
                    chapter.nameEn,
                    style: typography.body.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (canEdit)
              FPopoverMenu(
                semanticsLabel: 'Chapter actions',
                menuBuilder: (context, controller, _) => [
                  FItemGroup(
                    children: [
                      FItem(
                        title: const Text('Edit'),
                        onPress: () {
                          controller.hide();
                          onEdit();
                        },
                      ),
                      FItem(
                        title: Text(chapter.isArchived ? 'Restore' : 'Archive'),
                        onPress: () {
                          controller.hide();
                          onToggleArchive();
                        },
                      ),
                    ],
                  ),
                ],
                builder: (context, controller, _) => FButton.icon(
                  variant: .ghost,
                  size: .xs,
                  semanticsLabel: 'Chapter actions',
                  semanticsTooltip: 'Chapter actions',
                  onPress: controller.toggle,
                  child: const Icon(FPhosphorIcons.dotsThreeVertical, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TopicListPane extends StatelessWidget {
  const TopicListPane({
    super.key,
    required this.topics,
    required this.hasSelectedChapter,
    required this.canEdit,
    required this.canDelete,
    required this.onAddTopic,
    required this.onEditTopic,
    required this.onToggleArchive,
    required this.onDeleteTopic,
    required this.onReorder,
  });

  final List<Topic> topics;
  final bool hasSelectedChapter;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onAddTopic;
  final ValueChanged<Topic> onEditTopic;
  final ValueChanged<Topic> onToggleArchive;
  final ValueChanged<Topic> onDeleteTopic;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Topics',
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canEdit && hasSelectedChapter)
                  FButton(
                    variant: .outline,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: onAddTopic,
                    prefix: const Icon(FPhosphorIcons.plus, size: 15),
                    child: const Text('Add Topic'),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: !hasSelectedChapter
                ? const AppEmptyView(
                    title: 'Select a chapter',
                    subtitle: 'Choose a chapter to inspect or reorder topics.',
                    icon: FPhosphorIcons.tag,
                  )
                : topics.isEmpty
                ? const AppEmptyView(
                    title: 'No topics yet',
                    subtitle: 'Add granular concepts under this chapter.',
                    icon: FPhosphorIcons.tag,
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(10),
                    buildDefaultDragHandles: false,
                    itemCount: topics.length,
                    onReorderItem: onReorder,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Padding(
                        key: ValueKey(topic.id),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (canEdit)
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 8,
                                      top: 2,
                                    ),
                                    child: Icon(
                                      FPhosphorIcons.dotsSixVertical,
                                      size: 18,
                                      color: colors.mutedForeground,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            topic.nameBn,
                                            style: AppTypography.bangla(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (topic.isArchived)
                                          StatusBadge.neutral('Archived'),
                                      ],
                                    ),
                                    Text(
                                      topic.nameEn,
                                      style: typography.body.xs.copyWith(
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      topic.code,
                                      style: typography.body.xs.copyWith(
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (canEdit)
                                FPopoverMenu(
                                  semanticsLabel: 'Topic actions',
                                  menuBuilder: (context, controller, _) => [
                                    FItemGroup(
                                      children: [
                                        FItem(
                                          title: const Text('Edit'),
                                          onPress: () {
                                            controller.hide();
                                            onEditTopic(topic);
                                          },
                                        ),
                                        FItem(
                                          title: Text(
                                            topic.isArchived
                                                ? 'Restore'
                                                : 'Archive',
                                          ),
                                          onPress: () {
                                            controller.hide();
                                            onToggleArchive(topic);
                                          },
                                        ),
                                        if (canDelete)
                                          FItem(
                                            variant: .destructive,
                                            title: const Text(
                                              'Delete (Unreferenced)',
                                            ),
                                            onPress: () {
                                              controller.hide();
                                              onDeleteTopic(topic);
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                  builder: (context, controller, _) =>
                                      FButton.icon(
                                        variant: .ghost,
                                        size: .xs,
                                        semanticsLabel: 'Topic actions',
                                        semanticsTooltip: 'Topic actions',
                                        onPress: controller.toggle,
                                        child: const Icon(
                                          FPhosphorIcons.dotsThreeVertical,
                                          size: 16,
                                        ),
                                      ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
