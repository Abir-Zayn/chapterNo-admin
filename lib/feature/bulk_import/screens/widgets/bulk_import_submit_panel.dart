import 'imports/bulk_import_submit_panel_imports.dart';
import '../bloc/bulk_import_state.dart';

/// Submit bar: chunked import trigger, live chunk progress, and the final
/// {inserted, updated, total} summary.
class BulkImportSubmitPanel extends StatelessWidget {
  final bool canImport;
  final int validRowCount;
  final bool isSubmitting;
  final int submitChunksDone;
  final int submitChunksTotal;
  final BulkImportSubmitPhase submitPhase;
  final McqBatchUpsertResult? summary;
  final VoidCallback onSubmit;

  const BulkImportSubmitPanel({
    super.key,
    required this.canImport,
    required this.validRowCount,
    required this.isSubmitting,
    required this.submitChunksDone,
    required this.submitChunksTotal,
    required this.submitPhase,
    required this.summary,
    required this.onSubmit,
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
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: (canImport && validRowCount > 0 && !isSubmitting)
                    ? onSubmit
                    : null,
                icon: const Icon(PhosphorIconsRegular.uploadSimple),
                label: Text('Import $validRowCount valid rows'),
              ),
              if (isSubmitting)
                Text(
                  submitChunksTotal > 1
                      ? 'Uploading chunk $submitChunksDone / $submitChunksTotal…'
                      : 'Uploading…',
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.textSecondary,
                  ),
                ),
              if (isSubmitting)
                const Icon(
                  PhosphorIconsRegular.circleNotch,
                  size: 16,
                ),
            ],
          ),
          if (isSubmitting) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: submitChunksTotal > 0
                  ? submitChunksDone / submitChunksTotal
                  : null,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
          if (submitPhase == BulkImportSubmitPhase.success &&
              summary != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.successTint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.successBorder),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusBadge.active('Imported'),
                  Text(
                    'Inserted ${summary!.inserted} · Updated ${summary!.updated} · Total ${summary!.total}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: palette.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
