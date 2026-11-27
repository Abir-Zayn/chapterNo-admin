// Paginated Question Bank list with select-all header, rendered LaTeX previews,
// provenance chips, and quick role-aware moderation actions.
import 'imports/question_bank_list_view_imports.dart';

class QuestionBankListView extends StatelessWidget {
  const QuestionBankListView({
    super.key,
    required this.items,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    required this.showingFrom,
    required this.showingTo,
    required this.selectedIds,
    required this.role,
    required this.isFetching,
    required this.isModerating,
    required this.chapterLabelsById,
    required this.boardLabelsById,
    required this.onToggleSelect,
    required this.onToggleSelectAll,
    required this.onInspectQuestion,
    required this.onQuickAction,
    required this.onGoToPage,
  });

  final List<McqQuestion> items;
  final int totalCount;
  final int page;
  final int totalPages;
  final int showingFrom;
  final int showingTo;
  final Set<String> selectedIds;
  final AdminRole role;
  final bool isFetching;
  final bool isModerating;
  final Map<int, String> chapterLabelsById;
  final Map<String, String> boardLabelsById;
  final ValueChanged<String> onToggleSelect;
  final ValueChanged<List<String>> onToggleSelectAll;
  final ValueChanged<McqQuestion> onInspectQuestion;
  final void Function(McqQuestion question, QuestionBankModerationAction action)
  onQuickAction;
  final ValueChanged<int> onGoToPage;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final eligibleIds = items
        .where((q) => QuestionBankPermissions.canSelectForBulk(role, q))
        .map((q) => q.id)
        .toList();
    final allSelected =
        eligibleIds.isNotEmpty &&
        eligibleIds.every((id) => selectedIds.contains(id));

    return FCard(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.muted,
              border: Border(bottom: BorderSide(color: colors.border)),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FCheckbox(
                      value: allSelected,
                      enabled: eligibleIds.isNotEmpty,
                      onChange: (_) => onToggleSelectAll(eligibleIds),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      totalCount == 0
                          ? 'No matching questions'
                          : 'Showing $showingFrom–$showingTo of $totalCount',
                      style: typography.body.sm.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                    if (isFetching) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: FCircularProgress(size: .xs),
                      ),
                    ],
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Page $page of $totalPages',
                      style: typography.body.sm.copyWith(
                        fontSize: 12.5,
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FTooltip(
                      tipBuilder: (_, _) => const Text('Previous page'),
                      child: FButton(
                        variant: .ghost,
                        size: .sm,
                        mainAxisSize: .min,
                        onPress: page > 1 && !isFetching
                            ? () => onGoToPage(page - 1)
                            : null,
                        child: const Icon(FPhosphorIcons.caretLeft, size: 17),
                      ),
                    ),
                    FTooltip(
                      tipBuilder: (_, _) => const Text('Next page'),
                      child: FButton(
                        variant: .ghost,
                        size: .sm,
                        mainAxisSize: .min,
                        onPress: page < totalPages && !isFetching
                            ? () => onGoToPage(page + 1)
                            : null,
                        child: const Icon(FPhosphorIcons.caretRight, size: 17),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const AppEmptyView(
                    title: 'No Questions Found',
                    subtitle:
                        'Try adjusting your filters or import new MCQs from '
                        'the Bulk Importer.',
                    icon: FPhosphorIcons.database,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final question = items[index];
                      return _QuestionRowCard(
                        question: question,
                        isSelected: selectedIds.contains(question.id),
                        canSelect: QuestionBankPermissions.canSelectForBulk(
                          role,
                          question,
                        ),
                        role: role,
                        isModerating: isModerating,
                        chapterLabel: chapterLabelsById[question.chapterId],
                        boardLabel: question.boardId == null
                            ? null
                            : boardLabelsById[question.boardId],
                        onToggleSelect: () => onToggleSelect(question.id),
                        onInspect: () => onInspectQuestion(question),
                        onQuickAction: (action) =>
                            onQuickAction(question, action),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuestionRowCard extends StatelessWidget {
  const _QuestionRowCard({
    required this.question,
    required this.isSelected,
    required this.canSelect,
    required this.role,
    required this.isModerating,
    required this.chapterLabel,
    required this.boardLabel,
    required this.onToggleSelect,
    required this.onInspect,
    required this.onQuickAction,
  });

  final McqQuestion question;
  final bool isSelected;
  final bool canSelect;
  final AdminRole role;
  final bool isModerating;
  final String? chapterLabel;
  final String? boardLabel;
  final VoidCallback onToggleSelect;
  final VoidCallback onInspect;
  final ValueChanged<QuestionBankModerationAction> onQuickAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final dark = colors.brightness == Brightness.dark;
    final successForeground = dark
        ? const Color(0xFF4ADE80)
        : const Color(0xFF16A34A);
    final canQuickPublish = QuestionBankPermissions.canPerformAction(
      role: role,
      question: question,
      action: QuestionBankModerationAction.approveAndPublish,
    );

    return InkWell(
      onTap: onInspect,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.06)
              : colors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FCheckbox(
              value: isSelected,
              enabled: canSelect,
              onChange: (_) => onToggleSelect(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (question.externalCode != null)
                        Text(
                          question.externalCode!,
                          style: typography.body.xs.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: colors.mutedForeground,
                          ),
                        ),
                      _statusBadge(context, question.status),
                      if (question.isVerified)
                        StatusBadge(
                          label: 'Verified',
                          backgroundColor: dark
                              ? const Color(0xFF0F291A)
                              : const Color(0xFFF0FDF4),
                          foregroundColor: successForeground,
                          borderColor: dark
                              ? const Color(0xFF166534)
                              : const Color(0xFFBBF7D0),
                        ),
                      StatusBadge.neutral(question.difficulty.label),
                      StatusBadge.neutral(
                        question.examYear != null
                            ? '${question.sourceType.label} · ${question.examYear}'
                            : question.sourceType.label,
                      ),
                      if (chapterLabel != null)
                        StatusBadge.neutral(chapterLabel!),
                      if (boardLabel != null) StatusBadge.neutral(boardLabel!),
                      Text(
                        'v${question.version}',
                        style: typography.body.xs.copyWith(
                          fontSize: 11,
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SharedMathPreviewText(
                    text: question.title,
                    fontSize: 14,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Correct: Option ${question.correctOption} · '
                    '${question.options.length} options'
                    '${question.explanation != null ? ' · Has explanation' : ''}',
                    style: typography.body.xs.copyWith(
                      fontSize: 11.5,
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (canQuickPublish)
                  FTooltip(
                    tipBuilder: (_, _) => const Text('Approve & Publish'),
                    child: FButton(
                      variant: .ghost,
                      size: .sm,
                      mainAxisSize: .min,
                      onPress: isModerating
                          ? null
                          : () => onQuickAction(
                              QuestionBankModerationAction.approveAndPublish,
                            ),
                      child: Icon(
                        FPhosphorIcons.checkCircle,
                        size: 19,
                        color: successForeground,
                      ),
                    ),
                  ),
                FTooltip(
                  tipBuilder: (_, _) => const Text('Inspect details'),
                  child: FButton(
                    variant: .ghost,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: onInspect,
                    child: const Icon(FPhosphorIcons.eye, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(BuildContext context, McqStatus status) {
    final colors = context.theme.colors;
    final dark = colors.brightness == Brightness.dark;
    switch (status) {
      case McqStatus.published:
        return StatusBadge(
          label: 'Published',
          backgroundColor: dark
              ? const Color(0xFF0F291A)
              : const Color(0xFFF0FDF4),
          foregroundColor: dark
              ? const Color(0xFF4ADE80)
              : const Color(0xFF16A34A),
          borderColor: dark ? const Color(0xFF166534) : const Color(0xFFBBF7D0),
        );
      case McqStatus.inReview:
        return StatusBadge(
          label: 'In Review',
          backgroundColor: dark
              ? const Color(0xFF2A1F0A)
              : const Color(0xFFFFFBEB),
          foregroundColor: dark
              ? const Color(0xFFFBBF24)
              : const Color(0xFFD97706),
          borderColor: dark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
        );
      case McqStatus.draft:
        return StatusBadge.neutral('Draft');
      case McqStatus.archived:
        return StatusBadge(
          label: 'Archived',
          backgroundColor: colors.destructive,
          foregroundColor: colors.destructiveForeground,
          borderColor: colors.destructive,
        );
    }
  }
}
