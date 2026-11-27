// Create/Edit modal and archive confirmation dialogs for curriculum nodes.
// Supports Bangla UTF-8 input, auto-slugified codes, and inline error display.
import 'imports/curriculum_node_dialog_imports.dart';

class CurriculumNodeFormValues {
  const CurriculumNodeFormValues({
    required this.code,
    required this.nameBn,
    required this.nameEn,
    required this.displayOrder,
    this.academicGroup = AcademicGroup.common,
    this.nctbCode,
    this.shortNameBn,
    this.chapterNumber,
    this.descriptionBn,
    this.summaryBn,
  });

  final String code;
  final String nameBn;
  final String nameEn;
  final int displayOrder;
  final AcademicGroup academicGroup;
  final String? nctbCode;
  final String? shortNameBn;
  final int? chapterNumber;
  final String? descriptionBn;
  final String? summaryBn;
}

Future<bool> showArchiveConfirmationDialog(
  BuildContext context, {
  required String itemName,
  required bool isArchiving,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isArchiving ? 'Archive $itemName?' : 'Restore $itemName?'),
      content: Text(
        isArchiving
            ? 'Archiving hides this item from new student sessions without deleting existing questions or progress.'
            : 'Restoring makes this item visible again in active curriculum selections.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(isArchiving ? 'Archive' : 'Restore'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> showCurriculumNodeDialog(
  BuildContext context, {
  required CurriculumNodeKind kind,
  required bool isEditing,
  required Future<String?> Function(CurriculumNodeFormValues values) onSubmit,
  String codePrefix = '',
  String initialCode = '',
  String initialNameBn = '',
  String initialNameEn = '',
  int initialDisplayOrder = 1,
  AcademicGroup initialGroup = AcademicGroup.common,
  String? initialNctbCode,
  String? initialShortNameBn,
  int? initialChapterNumber,
  String? initialDescriptionBn,
  String? initialSummaryBn,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CurriculumNodeDialog(
      kind: kind,
      isEditing: isEditing,
      onSubmit: onSubmit,
      codePrefix: codePrefix,
      initialCode: initialCode,
      initialNameBn: initialNameBn,
      initialNameEn: initialNameEn,
      initialDisplayOrder: initialDisplayOrder,
      initialGroup: initialGroup,
      initialNctbCode: initialNctbCode,
      initialShortNameBn: initialShortNameBn,
      initialChapterNumber: initialChapterNumber,
      initialDescriptionBn: initialDescriptionBn,
      initialSummaryBn: initialSummaryBn,
    ),
  );
}

class _CurriculumNodeDialog extends StatefulWidget {
  const _CurriculumNodeDialog({
    required this.kind,
    required this.isEditing,
    required this.onSubmit,
    required this.codePrefix,
    required this.initialCode,
    required this.initialNameBn,
    required this.initialNameEn,
    required this.initialDisplayOrder,
    required this.initialGroup,
    this.initialNctbCode,
    this.initialShortNameBn,
    this.initialChapterNumber,
    this.initialDescriptionBn,
    this.initialSummaryBn,
  });

  final CurriculumNodeKind kind;
  final bool isEditing;
  final Future<String?> Function(CurriculumNodeFormValues values) onSubmit;
  final String codePrefix;
  final String initialCode;
  final String initialNameBn;
  final String initialNameEn;
  final int initialDisplayOrder;
  final AcademicGroup initialGroup;
  final String? initialNctbCode;
  final String? initialShortNameBn;
  final int? initialChapterNumber;
  final String? initialDescriptionBn;
  final String? initialSummaryBn;

  @override
  State<_CurriculumNodeDialog> createState() => _CurriculumNodeDialogState();
}

class _CurriculumNodeDialogState extends State<_CurriculumNodeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameBnController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _codeController;
  late final TextEditingController _orderController;
  late final TextEditingController _nctbCodeController;
  late final TextEditingController _shortNameBnController;
  late final TextEditingController _chapterNumberController;
  late final TextEditingController _extraBnController;

  late AcademicGroup _selectedGroup;
  bool _codeManuallyEdited = false;
  bool _isSaving = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _nameBnController = TextEditingController(text: widget.initialNameBn);
    _nameEnController = TextEditingController(text: widget.initialNameEn);
    _codeController = TextEditingController(text: widget.initialCode);
    _orderController = TextEditingController(
      text: widget.initialDisplayOrder.toString(),
    );
    _nctbCodeController = TextEditingController(
      text: widget.initialNctbCode ?? '',
    );
    _shortNameBnController = TextEditingController(
      text: widget.initialShortNameBn ?? '',
    );
    _chapterNumberController = TextEditingController(
      text: (widget.initialChapterNumber ?? 1).toString(),
    );
    _extraBnController = TextEditingController(
      text: widget.kind == CurriculumNodeKind.chapter
          ? (widget.initialDescriptionBn ?? '')
          : (widget.initialSummaryBn ?? ''),
    );
    _selectedGroup = widget.initialGroup;
    _codeManuallyEdited = widget.isEditing || widget.initialCode.isNotEmpty;
  }

  @override
  void dispose() {
    _nameBnController.dispose();
    _nameEnController.dispose();
    _codeController.dispose();
    _orderController.dispose();
    _nctbCodeController.dispose();
    _shortNameBnController.dispose();
    _chapterNumberController.dispose();
    _extraBnController.dispose();
    super.dispose();
  }

  void _onEnglishChanged(String value) {
    if (_codeManuallyEdited) return;
    _codeController.text = CurriculumValidators.suggestCode(
      value,
      prefix: widget.codePrefix,
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSaving = true;
      _inlineError = null;
    });

    final values = CurriculumNodeFormValues(
      code: _codeController.text.trim(),
      nameBn: _nameBnController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      displayOrder: int.parse(_orderController.text.trim()),
      academicGroup: _selectedGroup,
      nctbCode: _nctbCodeController.text.trim(),
      shortNameBn: _shortNameBnController.text.trim(),
      chapterNumber: widget.kind == CurriculumNodeKind.chapter
          ? int.parse(_chapterNumberController.text.trim())
          : null,
      descriptionBn: widget.kind == CurriculumNodeKind.chapter
          ? _extraBnController.text.trim()
          : null,
      summaryBn: widget.kind == CurriculumNodeKind.topic
          ? _extraBnController.text.trim()
          : null,
    );

    final error = await widget.onSubmit(values);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSaving = false;
      _inlineError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing
        ? 'Edit ${widget.kind.label}'
        : 'Add ${widget.kind.label}';

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_inlineError != null) ...[
                  AppErrorBanner(
                    message: _inlineError!,
                    onDismiss: () => setState(() => _inlineError = null),
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _nameBnController,
                  enabled: !_isSaving,
                  style: AppTypography.bangla(fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'Bangla Name (বাংলা নাম) *',
                    hintText: 'যেমন: পদার্থবিজ্ঞান',
                  ),
                  validator: CurriculumValidators.requiredBangla,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameEnController,
                  enabled: !_isSaving,
                  onChanged: _onEnglishChanged,
                  decoration: const InputDecoration(
                    labelText: 'English Name *',
                    hintText: 'e.g., Physics',
                  ),
                  validator: CurriculumValidators.requiredEnglish,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeController,
                  enabled: !_isSaving,
                  onChanged: (_) => _codeManuallyEdited = true,
                  decoration: const InputDecoration(
                    labelText: 'Code *',
                    hintText: 'e.g., ssc_phy_ch01',
                  ),
                  validator: CurriculumValidators.code,
                ),
                const SizedBox(height: 12),
                if (widget.kind == CurriculumNodeKind.subject) ...[
                  DropdownButtonFormField<AcademicGroup>(
                    initialValue: _selectedGroup,
                    decoration: const InputDecoration(
                      labelText: 'Academic Group',
                    ),
                    items: AcademicGroup.values
                        .map(
                          (group) => DropdownMenuItem(
                            value: group,
                            child: Text('${group.labelBn} (${group.labelEn})'),
                          ),
                        )
                        .toList(),
                    onChanged: _isSaving
                        ? null
                        : (group) {
                            if (group != null) {
                              setState(() => _selectedGroup = group);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nctbCodeController,
                          enabled: !_isSaving,
                          decoration: const InputDecoration(
                            labelText: 'NCTB Code',
                            hintText: 'e.g., 136',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _shortNameBnController,
                          enabled: !_isSaving,
                          style: AppTypography.bangla(fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Short Name (বাংলা)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (widget.kind == CurriculumNodeKind.chapter) ...[
                  TextFormField(
                    controller: _chapterNumberController,
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Chapter Number *',
                    ),
                    validator: CurriculumValidators.positiveInt,
                  ),
                  const SizedBox(height: 12),
                ],
                if (widget.kind == CurriculumNodeKind.chapter ||
                    widget.kind == CurriculumNodeKind.topic) ...[
                  TextFormField(
                    controller: _extraBnController,
                    enabled: !_isSaving,
                    maxLines: 2,
                    style: AppTypography.bangla(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: widget.kind == CurriculumNodeKind.chapter
                          ? 'Description (বাংলা)'
                          : 'Summary (বাংলা)',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _orderController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Display Order'),
                  validator: CurriculumValidators.nonNegativeInt,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.isEditing ? 'Save Changes' : 'Create'),
        ),
      ],
    );
  }
}
