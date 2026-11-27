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
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.table,
                size: 18,
                color: palette.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Preview & Validation',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
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
                color: palette.primary,
              ),
              _CounterChip(
                label: 'Valid',
                value: validRowCount,
                color: palette.success,
              ),
              _CounterChip(
                label: 'Errors',
                value: errorRowCount,
                color: palette.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<RowViewFilter>(
            segments: [
              for (final filter in RowViewFilter.values)
                ButtonSegment(
                  value: filter,
                  label: Text(filter.label),
                ),
            ],
            selected: {rowFilter},
            onSelectionChanged: (selection) =>
                onSetRowFilter(selection.first),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(context, palette)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppPalette palette) {
    if (totalRows == 0) {
      return Center(
        child: Text(
          'No rows to preview yet — pick a file or paste CSV / JSON and parse.',
          style: TextStyle(color: palette.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (rows.isEmpty) {
      return Center(
        child: Text(
          'No rows match the current filter.',
          style: TextStyle(color: palette.textSecondary, fontSize: 13),
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
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: palette.textSecondary,
            ),
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
    final palette = AppPalette.of(context);
    final levelLabel = McqLevel.tryParse(row.level)?.label ?? row.level;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: row.isValid ? palette.border : palette.error.withValues(alpha: 0.35),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: !row.isValid && row.errors.isNotEmpty,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '#${row.rowNumber}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
              if (row.externalCode != null)
                Text(
                  row.externalCode!,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: palette.textSecondary,
                  ),
                ),
              StatusBadge.neutral(levelLabel),
              if (row.isValid)
                StatusBadge.active('Valid')
              else
                StatusBadge(
                  label: '${row.errors.length} error(s)',
                  backgroundColor: palette.errorTint,
                  foregroundColor: palette.error,
                  borderColor: palette.error.withValues(alpha: 0.35),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: MathPreviewText(
              text: row.title.isEmpty ? '(empty title)' : row.title,
              fontSize: 13,
            ),
          ),
          children: [
            for (final error in row.errors)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: palette.errorTint,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: palette.error.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(fontSize: 12, color: palette.error),
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
                        PhosphorIconsRegular.checkCircle,
                        size: 16,
                        color: palette.success,
                      )
                    else
                      Icon(
                        PhosphorIconsRegular.circle,
                        size: 16,
                        color: palette.border,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      '${option.key}:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: option.isBlank
                          ? Text(
                              '(blank)',
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textSecondary,
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
            if (row.explanation != null && row.explanation!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Explanation',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              MathPreviewText(text: row.explanation!, fontSize: 13),
            ],
            if (row.resolvedChapterId != null) ...[
              const SizedBox(height: 6),
              Text(
                'Resolves to chapter_id ${row.resolvedChapterId}',
                style: TextStyle(
                  fontSize: 11,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
