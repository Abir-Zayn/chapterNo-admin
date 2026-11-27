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
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FButton(
                mainAxisSize: .min,
                onPress: (canImport && validRowCount > 0 && !isSubmitting)
                    ? onSubmit
                    : null,
                prefix: const Icon(FPhosphorIcons.uploadSimple),
                child: Text('Import $validRowCount valid rows'),
              ),
              if (isSubmitting)
                Text(
                  submitChunksTotal > 1
                      ? 'Uploading chunk $submitChunksDone / $submitChunksTotal…'
                      : 'Uploading…',
                  style: typography.body.sm.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              if (isSubmitting) const FCircularProgress(size: .xs),
            ],
          ),
          if (isSubmitting) ...[
            const SizedBox(height: 12),
            if (submitChunksTotal > 0)
              FDeterminateProgress(value: submitChunksDone / submitChunksTotal)
            else
              const FProgress(),
          ],
          if (submitPhase == BulkImportSubmitPhase.success &&
              summary != null) ...[
            const SizedBox(height: 12),
            FAlert(
              icon: const Icon(FPhosphorIcons.checkCircle),
              title: Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusBadge.active('Imported'),
                  Text(
                    'Inserted ${summary!.inserted} · Updated ${summary!.updated} · Total ${summary!.total}',
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
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
