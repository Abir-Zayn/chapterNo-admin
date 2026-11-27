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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(FPhosphorIcons.fileCsv, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Import Source',
                  style: typography.body.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (sourceName != null)
                FButton(
                  variant: .outline,
                  size: .sm,
                  mainAxisSize: .min,
                  onPress: canImport ? onClearSource : null,
                  prefix: const Icon(FPhosphorIcons.trash, size: 15),
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in ImportInputMode.values)
                FButton(
                  variant: inputMode == mode ? .primary : .outline,
                  size: .sm,
                  mainAxisSize: .min,
                  prefix: Icon(
                    mode == ImportInputMode.file
                        ? FPhosphorIcons.uploadSimple
                        : FPhosphorIcons.clipboardText,
                    size: 16,
                  ),
                  onPress: canImport
                      ? () {
                          if (mode != inputMode) onSetInputMode(mode);
                        }
                      : null,
                  child: Text(mode.label),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (inputMode == ImportInputMode.file) ...[
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: canImport ? () => _pickFile(context) : null,
                  prefix: const Icon(FPhosphorIcons.filePlus, size: 16),
                  child: const Text('Pick .csv / .json file'),
                ),
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => _copySample(context),
                  prefix: const Icon(FPhosphorIcons.copy, size: 16),
                  child: const Text('Copy Sample CSV'),
                ),
              ],
            ),
            if (sourceName != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    FPhosphorIcons.checkCircle,
                    size: 16,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Loaded: $sourceName',
                      overflow: TextOverflow.ellipsis,
                      style: typography.body.sm.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            FTextField(
              enabled: canImport,
              control: FTextFieldControl.managed(
                onChange: (value) => onUpdateSourceText(value.text),
              ),
              maxLines: 6,
              minLines: 6,
              hint:
                  'Paste CSV or JSON rows directly from Gemini Web or '
                  'Google Sheets...',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FButton(
                  mainAxisSize: .min,
                  onPress: canImport ? onParseSourceText : null,
                  prefix: const Icon(FPhosphorIcons.magicWand, size: 16),
                  child: const Text('Parse & Validate'),
                ),
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => _copySample(context),
                  prefix: const Icon(FPhosphorIcons.copy, size: 16),
                  child: const Text('Copy Sample CSV'),
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return FAccordion(
      control: const FAccordionControl.managed(max: 1),
      children: [
        FAccordionItem(
          title: Text(
            'View expected CSV format',
            style: typography.body.sm.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          dividerBuilder: (_, _) => const SizedBox.shrink(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: SelectableText(
              sampleCsv,
              style: typography.body.xs.copyWith(
                fontFamily: 'monospace',
                color: colors.foreground,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
