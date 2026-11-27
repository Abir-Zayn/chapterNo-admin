import 'imports/bulk_import_preview_table_imports.dart';

/// Filterable, mobile-friendly preview of parsed MCQ rows with per-row
/// validation badges and expandable details (LaTeX-rendered title/options).
class BulkImportPreviewTable extends StatelessWidget {
  final List<McqRowDraft> rows;
  final int totalRows;
  final int validRowCount;
  final int errorRowCount;
  final RowViewFilter rowFilter;
  final ValueChanged<RowViewFilter> onSetRowFilter;

  const BulkImportPreviewTable({
    super.key,
    required this.rows,
    required this.totalRows,
    required this.validRowCount,
    required this.errorRowCount,
    required this.rowFilter,
    required this.onSetRowFilter,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                FPhosphorIcons.table,
                size: 18,
                color: colors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Text(
                'Preview & Validation',
                style: typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _CounterChip(
                label: 'Total',
                value: totalRows,
                color: colors.primary,
              ),
              _CounterChip(
                label: 'Valid',
                value: validRowCount,
                color: colors.primary,
              ),
              _CounterChip(
                label: 'Errors',
                value: errorRowCount,
                color: colors.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final filter in RowViewFilter.values)
                FButton(
                  variant: rowFilter == filter ? .primary : .outline,
                  size: .sm,
                  mainAxisSize: .min,
                  onPress: () {
                    if (filter != rowFilter) onSetRowFilter(filter);
                  },
                  child: Text(filter.label),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    if (totalRows == 0) {
      return Center(
        child: Text(
          'No rows to preview yet — pick a file or paste CSV / JSON and parse.',
          style: typography.body.sm.copyWith(color: colors.mutedForeground),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (rows.isEmpty) {
      return Center(
        child: Text(
          'No rows match the current filter.',
          style: typography.body.sm.copyWith(color: colors.mutedForeground),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _PreviewRowCard(row: rows[index]),
    );
  }
}

class _CounterChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CounterChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: typography.body.xs.copyWith(color: colors.mutedForeground),
          ),
        ],
      ),
    );
  }
}

class _PreviewRowCard extends StatelessWidget {
  final McqRowDraft row;

  const _PreviewRowCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final levelLabel = McqLevel.tryParse(row.level)?.label ?? row.level;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: row.isValid
              ? colors.border
              : colors.error.withValues(alpha: 0.35),
        ),
      ),
      child: FAccordion(
        control: const FAccordionControl.managed(max: 1),
        children: [
          FAccordionItem(
            initiallyExpanded: !row.isValid && row.errors.isNotEmpty,
            dividerBuilder: (_, _) => const SizedBox.shrink(),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '#${row.rowNumber}',
                        style: typography.body.xs.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.mutedForeground,
                        ),
                      ),
                      if (row.externalCode != null)
                        Text(
                          row.externalCode!,
                          style: typography.body.xs.copyWith(
                            fontFamily: 'monospace',
                            color: colors.mutedForeground,
                          ),
                        ),
                      StatusBadge.neutral(levelLabel),
                      if (row.isValid)
                        StatusBadge.active('Valid')
                      else
                        StatusBadge(
                          label: '${row.errors.length} error(s)',
                          backgroundColor: colors.error.withValues(alpha: 0.1),
                          foregroundColor: colors.error,
                          borderColor: colors.error.withValues(alpha: 0.35),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: MathPreviewText(
                      text: row.title.isEmpty ? '(empty title)' : row.title,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final error in row.errors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: colors.error.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          error,
                          style: typography.body.xs.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ),
                  for (final option in row.options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (option.key == row.correctAns)
                            Icon(
                              FPhosphorIcons.checkCircle,
                              size: 16,
                              color: colors.primary,
                            )
                          else
                            Icon(
                              FPhosphorIcons.circle,
                              size: 16,
                              color: colors.border,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            '${option.key}:',
                            style: typography.body.xs.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: option.isBlank
                                ? Text(
                                    '(blank)',
                                    style: typography.body.xs.copyWith(
                                      color: colors.mutedForeground,
                                    ),
                                  )
                                : MathPreviewText(
                                    text: option.text,
                                    fontSize: 13,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  if (row.explanation != null &&
                      row.explanation!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Explanation',
                      style: typography.body.xs.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    MathPreviewText(text: row.explanation!, fontSize: 13),
                  ],
                  if (row.resolvedChapterId != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Resolves to chapter_id ${row.resolvedChapterId}',
                      style: typography.body.xs.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
