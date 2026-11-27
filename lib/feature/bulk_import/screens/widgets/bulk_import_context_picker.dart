// Context picker for the import target: Education Level -> Subject with
// optional default Chapter and Board applied when CSV rows omit them.
import 'imports/bulk_import_context_picker_imports.dart';

class BulkImportContextPicker extends StatelessWidget {
  const BulkImportContextPicker({
    super.key,
    required this.levels,
    required this.subjects,
    required this.chapters,
    required this.boards,
    required this.selectedLevelId,
    required this.selectedSubjectId,
    required this.selectedChapterId,
    required this.selectedBoardId,
    required this.isLoadingChapters,
    required this.onSelectLevel,
    required this.onSelectSubject,
    required this.onSelectChapter,
    required this.onSelectBoard,
  });

  final List<EducationLevel> levels;
  final List<Subject> subjects;
  final List<Chapter> chapters;
  final List<Board> boards;
  final String? selectedLevelId;
  final String? selectedSubjectId;
  final String? selectedChapterId;
  final String? selectedBoardId;
  final bool isLoadingChapters;
  final ValueChanged<String> onSelectLevel;
  final ValueChanged<String> onSelectSubject;
  final ValueChanged<String?> onSelectChapter;
  final ValueChanged<String?> onSelectBoard;

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
              const Icon(PhosphorIconsRegular.crosshair, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Import Target',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildField(
                context,
                label: 'Education Level',
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedLevelId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: [
                    for (final level in levels)
                      DropdownMenuItem(
                        value: level.id,
                        child: Text(
                          '${level.nameEn} (${level.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged:
                      levels.isEmpty
                      ? null
                      : (value) {
                          if (value != null) onSelectLevel(value);
                        },
                ),
              ),
              _buildField(
                context,
                label: 'Subject',
                width: 240,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedSubjectId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: [
                    for (final subject in subjects)
                      DropdownMenuItem(
                        value: subject.id,
                        child: Text(
                          subject.nameBn,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bangla(fontSize: 13.5),
                        ),
                      ),
                  ],
                  onChanged:
                      subjects.isEmpty
                      ? null
                      : (value) {
                          if (value != null) onSelectSubject(value);
                        },
                ),
              ),
              _buildField(
                context,
                label: 'Default Chapter (optional)',
                width: 240,
                child: isLoadingChapters
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : DropdownButtonFormField<String?>(
                        initialValue: selectedChapterId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Default chapter',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None — use chapter_code'),
                          ),
                          for (final chapter in chapters)
                            DropdownMenuItem<String?>(
                              value: chapter.id,
                              child: Text(
                                '${chapter.code} — ${chapter.nameBn}',
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bangla(fontSize: 13.5),
                              ),
                            ),
                        ],
                        onChanged: (value) => onSelectChapter(value),
                      ),
              ),
              _buildField(
                context,
                label: 'Default Board (optional)',
                width: 220,
                child: DropdownButtonFormField<String?>(
                  initialValue: selectedBoardId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Board'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None'),
                    ),
                    for (final board in boards)
                      DropdownMenuItem<String?>(
                        value: board.id,
                        child: Text(
                          board.nameEn,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => onSelectBoard(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required double width,
    required Widget child,
  }) {
    final palette = AppPalette.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: palette.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
