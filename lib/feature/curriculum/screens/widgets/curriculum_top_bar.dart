// Editorial overview card and filter bar inspired by Shop Manager stats card.
// Displays two-column syllabus summary metrics above level, search, and tab controls.
import 'imports/curriculum_top_bar_imports.dart';

class CurriculumTopBar extends StatelessWidget {
  const CurriculumTopBar({
    super.key,
    required this.state,
    required this.searchController,
    required this.isReviewer,
  });

  final CurriculumState state;
  final TextEditingController searchController;
  final bool isReviewer;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final cubit = context.read<CurriculumCubit>();
    final isWide = MediaQuery.sizeOf(context).width >= 820;

    final totalTopics = state.chapters.fold<int>(
      0,
      (sum, c) => sum + c.topics.length,
    );
    final activeSubjects = state.subjects.where((s) => !s.isArchived).length;
    final activeBoards = state.boards.where((b) => !b.isArchived).length;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Curriculum Catalogue',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    if (isReviewer) StatusBadge.neutral('Read-only (Reviewer)'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Controlled source of truth for NCTB syllabus hierarchy: Level → Board → Subject → Chapter → Topic.',
                  style: TextStyle(fontSize: 13, color: palette.textSecondary),
                ),
                const SizedBox(height: 16),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _OverviewColumn(
                          heading: 'Syllabus hierarchy',
                          rows: [
                            _StatRow(
                              icon: PhosphorIconsRegular.books,
                              label: 'Subjects in selected level',
                              count: activeSubjects,
                            ),
                            _StatRow(
                              icon: PhosphorIconsRegular.listNumbers,
                              label: 'Chapters in selected subject',
                              count: state.chapters.length,
                            ),
                            _StatRow(
                              icon: PhosphorIconsRegular.tag,
                              label: 'Topics in selected subject',
                              count: totalTopics,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _OverviewColumn(
                          heading: 'Coverage & boards',
                          rows: [
                            _StatRow(
                              icon: PhosphorIconsRegular.graduationCap,
                              label: 'Education levels',
                              count: state.levels.length,
                            ),
                            _StatRow(
                              icon: PhosphorIconsRegular.buildings,
                              label: 'Active education boards',
                              count: activeBoards,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (state.levels.isNotEmpty)
                  SizedBox(
                    width: 215,
                    child: DropdownButtonFormField<String>(
                      initialValue: state.selectedLevelId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Education Level',
                      ),
                      items: state.levels
                          .map(
                            (level) => DropdownMenuItem(
                              value: level.id,
                              child: Text(
                                '${level.nameEn} (${level.nameBn})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) cubit.selectLevel(value);
                      },
                    ),
                  ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: searchController,
                    onChanged: cubit.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'Search Bangla, English, or code...',
                      prefixIcon: Icon(
                        PhosphorIconsRegular.magnifyingGlass,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: state.showArchived,
                      onChanged: cubit.toggleShowArchived,
                    ),
                    const SizedBox(width: 4),
                    const Text('Show Archived', style: TextStyle(fontSize: 13)),
                  ],
                ),
                SegmentedButton<CurriculumTab>(
                  segments: const [
                    ButtonSegment(
                      value: CurriculumTab.syllabus,
                      label: Text('Subjects & Syllabus'),
                    ),
                    ButtonSegment(
                      value: CurriculumTab.boardsAndLevels,
                      label: Text('Boards & Levels'),
                    ),
                  ],
                  selected: {state.activeTab},
                  onSelectionChanged: (values) => cubit.setTab(values.first),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewColumn extends StatelessWidget {
  const _OverviewColumn({required this.heading, required this.rows});

  final String heading;
  final List<_StatRow> rows;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: palette.primaryTint,
            shape: BoxShape.circle,
            border: Border.all(color: palette.border),
          ),
          child: Icon(icon, size: 14, color: palette.textPrimary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              color: palette.textPrimary,
              decoration: TextDecoration.underline,
              decorationColor: palette.border,
            ),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
