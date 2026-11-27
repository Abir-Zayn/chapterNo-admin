// Source input panel: file picker tab, paste tab, and sample CSV helpers.
// Supports .csv / .json uploads and direct paste from Gemini or Sheets.
import 'imports/bulk_import_source_panel_imports.dart';

class BulkImportSourcePanel extends StatelessWidget {
  const BulkImportSourcePanel({
    super.key,
    required this.inputMode,
    required this.sourceName,
    required this.sourceText,
    required this.canImport,
    required this.onSetInputMode,
    required this.onUpdateSourceText,
    required this.onParseSourceText,
    required this.onIngestFile,
    required this.onClearSource,
  });

  final ImportInputMode inputMode;
  final String? sourceName;
  final String sourceText;
  final bool canImport;
  final ValueChanged<ImportInputMode> onSetInputMode;
  final ValueChanged<String> onUpdateSourceText;
  final VoidCallback onParseSourceText;
  final void Function({required List<int> bytes, required String name})
  onIngestFile;
  final VoidCallback onClearSource;

  Future<void> _pickFile(BuildContext context) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'json'],
    );
    if (files.isEmpty) return;
    final file = files.first;
    final bytes = await file.readAsBytes();
    onIngestFile(bytes: bytes, name: file.name);
  }

  Future<void> _copySample(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: sampleCsv));
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: const Text('Sample CSV copied to clipboard.'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(PhosphorIconsRegular.fileCsv, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Import Source',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              if (sourceName != null)
                OutlinedButton.icon(
                  onPressed: canImport ? onClearSource : null,
                  icon: const Icon(PhosphorIconsRegular.trash, size: 15),
                  label: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<ImportInputMode>(
            segments: [
              ButtonSegment(
                value: ImportInputMode.file,
                icon: const Icon(PhosphorIconsRegular.uploadSimple, size: 16),
                label: Text(ImportInputMode.file.label),
              ),
              ButtonSegment(
                value: ImportInputMode.paste,
                icon: const Icon(PhosphorIconsRegular.clipboardText, size: 16),
                label: Text(ImportInputMode.paste.label),
              ),
            ],
            selected: {inputMode},
            onSelectionChanged: canImport
                ? (values) => onSetInputMode(values.first)
                : null,
          ),
          const SizedBox(height: 12),
          if (inputMode == ImportInputMode.file) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canImport ? () => _pickFile(context) : null,
                    icon: const Icon(
                      PhosphorIconsRegular.filePlus,
                      size: 16,
                    ),
                    label: const Text('Pick .csv / .json file'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copySample(context),
                    icon: const Icon(PhosphorIconsRegular.copy, size: 16),
                    label: const Text('Copy Sample CSV'),
                  ),
                ),
              ],
            ),
            if (sourceName != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.checkCircle,
                    size: 16,
                    color: palette.success,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Loaded: $sourceName',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            TextField(
              enabled: canImport,
              maxLines: 6,
              onChanged: onUpdateSourceText,
              decoration: const InputDecoration(
                hintText:
                    'Paste CSV or JSON rows directly from Gemini Web or '
                    'Google Sheets...',
                counterText: '',
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: canImport ? onParseSourceText : null,
                  icon: const Icon(PhosphorIconsRegular.magicWand, size: 16),
                  label: const Text('Parse & Validate'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _copySample(context),
                  icon: const Icon(PhosphorIconsRegular.copy, size: 16),
                  label: const Text('Copy Sample CSV'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _SampleCsvDisclosure(),
        ],
      ),
    );
  }
}

class _SampleCsvDisclosure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          'View expected CSV format',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.border),
            ),
            child: SelectableText(
              sampleCsv,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.5,
                color: palette.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
