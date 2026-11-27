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
              const Icon(FPhosphorIcons.crosshair, size: 18),
              const SizedBox(width: 8),
              Text(
                'Import Target',
                style: typography.body.lg.copyWith(fontWeight: FontWeight.w600),
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
                child: FSelect<String>.rich(
                  label: const Text('Level'),
                  enabled: levels.isNotEmpty,
                  control: FSelectControl<String>.managed(
                    initial: selectedLevelId,
                    onChange: (value) {
                      if (value != null) onSelectLevel(value);
                    },
                  ),
                  format: _levelLabel,
                  children: [
                    for (final level in levels)
                      FSelectItem<String>(
                        value: level.id,
                        title: Text(
                          '${level.nameEn} (${level.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              _buildField(
                context,
                label: 'Subject',
                width: 240,
                child: FSelect<String>.rich(
                  label: const Text('Subject'),
                  enabled: subjects.isNotEmpty,
                  control: FSelectControl<String>.managed(
                    initial: selectedSubjectId,
                    onChange: (value) {
                      if (value != null) onSelectSubject(value);
                    },
                  ),
                  format: _subjectLabel,
                  children: [
                    for (final subject in subjects)
                      FSelectItem<String>(
                        value: subject.id,
                        title: Text(
                          subject.nameBn,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bangla(fontSize: 13.5),
                        ),
                      ),
                  ],
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
                          child: FCircularProgress(size: .sm),
                        ),
                      )
                    : FSelect<String?>.rich(
                        label: const Text('Default chapter'),
                        control: FSelectControl<String?>.managed(
                          initial: selectedChapterId,
                          onChange: onSelectChapter,
                        ),
                        format: _chapterLabel,
                        children: [
                          const FSelectItem<String?>(
                            value: null,
                            title: Text('None — use chapter_code'),
                          ),
                          for (final chapter in chapters)
                            FSelectItem<String?>(
                              value: chapter.id,
                              title: Text(
                                '${chapter.code} — ${chapter.nameBn}',
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bangla(fontSize: 13.5),
                              ),
                            ),
                        ],
                      ),
              ),
              _buildField(
                context,
                label: 'Default Board (optional)',
                width: 220,
                child: FSelect<String?>.rich(
                  label: const Text('Board'),
                  control: FSelectControl<String?>.managed(
                    initial: selectedBoardId,
                    onChange: onSelectBoard,
                  ),
                  format: _boardLabel,
                  children: [
                    const FSelectItem<String?>(
                      value: null,
                      title: Text('None'),
                    ),
                    for (final board in boards)
                      FSelectItem<String?>(
                        value: board.id,
                        title: Text(
                          board.nameEn,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _levelLabel(String id) {
    final level = levels.firstWhere((level) => level.id == id);
    return '${level.nameEn} (${level.code})';
  }

  String _subjectLabel(String id) {
    return subjects.firstWhere((subject) => subject.id == id).nameBn;
  }

  String _chapterLabel(String? id) {
    if (id == null) return 'None — use chapter_code';
    final chapter = chapters.firstWhere((chapter) => chapter.id == id);
    return '${chapter.code} — ${chapter.nameBn}';
  }

  String _boardLabel(String? id) {
    if (id == null) return 'None';
    return boards.firstWhere((board) => board.id == id).nameEn;
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required double width,
    required Widget child,
  }) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.body.xs.copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
