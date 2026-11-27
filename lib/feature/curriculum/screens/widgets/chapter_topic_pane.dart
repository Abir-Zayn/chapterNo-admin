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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Chapters',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                if (canEdit && hasSelectedSubject)
                  FilledButton.tonalIcon(
                    onPressed: onAddChapter,
                    icon: const Icon(PhosphorIconsRegular.plus, size: 15),
                    label: const Text('Add Chapter'),
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
                    icon: PhosphorIconsRegular.bookOpen,
                  )
                : isLoading
                ? const AppLoadingView(message: 'Loading chapters...')
                : chapters.isEmpty
                ? const AppEmptyView(
                    title: 'No chapters yet',
                    subtitle:
                        'Add the first textbook chapter for this subject.',
                    icon: PhosphorIconsRegular.listNumbers,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTint : AppColors.canvas,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canEdit)
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8, top: 2),
                  child: Icon(
                    PhosphorIconsRegular.dotsSixVertical,
                    size: 18,
                    color: AppColors.textSecondary,
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
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
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
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    chapter.nameEn,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (canEdit)
              PopupMenuButton<String>(
                tooltip: 'Chapter actions',
                icon: const Icon(
                  PhosphorIconsRegular.dotsThreeVertical,
                  size: 16,
                ),
                onSelected: (action) {
                  if (action == 'edit') onEdit();
                  if (action == 'archive') onToggleArchive();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(chapter.isArchived ? 'Restore' : 'Archive'),
                  ),
                ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Topics',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                if (canEdit && hasSelectedChapter)
                  FilledButton.tonalIcon(
                    onPressed: onAddTopic,
                    icon: const Icon(PhosphorIconsRegular.plus, size: 15),
                    label: const Text('Add Topic'),
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
                    icon: PhosphorIconsRegular.tag,
                  )
                : topics.isEmpty
                ? const AppEmptyView(
                    title: 'No topics yet',
                    subtitle: 'Add granular concepts under this chapter.',
                    icon: PhosphorIconsRegular.tag,
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
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (canEdit)
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 8, top: 2),
                                    child: Icon(
                                      PhosphorIconsRegular.dotsSixVertical,
                                      size: 18,
                                      color: AppColors.textSecondary,
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
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      topic.code,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (canEdit)
                                PopupMenuButton<String>(
                                  tooltip: 'Topic actions',
                                  icon: const Icon(
                                    PhosphorIconsRegular.dotsThreeVertical,
                                    size: 16,
                                  ),
                                  onSelected: (action) {
                                    if (action == 'edit') onEditTopic(topic);
                                    if (action == 'archive') {
                                      onToggleArchive(topic);
                                    }
                                    if (action == 'delete') {
                                      onDeleteTopic(topic);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'archive',
                                      child: Text(
                                        topic.isArchived
                                            ? 'Restore'
                                            : 'Archive',
                                      ),
                                    ),
                                    if (canDelete)
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          'Delete (Unreferenced)',
                                          style: TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                  ],
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
