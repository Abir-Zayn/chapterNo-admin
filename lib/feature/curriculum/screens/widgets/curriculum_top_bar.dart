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
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final cubit = context.read<CurriculumCubit>();
    final isWide = MediaQuery.sizeOf(context).width >= 820;

    final totalTopics = state.chapters.fold<int>(
      0,
      (sum, c) => sum + c.topics.length,
    );
    final activeSubjects = state.subjects.where((s) => !s.isArchived).length;
    final activeBoards = state.boards.where((b) => !b.isArchived).length;

    String levelLabel(String id) {
      final level = state.levels.firstWhere((level) => level.id == id);
      return '${level.nameEn} (${level.nameBn})';
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Curriculum Catalogue',
                      style: typography.body.xl2.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (isReviewer) StatusBadge.neutral('Read-only (Reviewer)'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Controlled source of truth for NCTB syllabus hierarchy: Level → Board → Subject → Chapter → Topic.',
                  style: typography.body.sm.copyWith(
                    color: colors.mutedForeground,
                  ),
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
                              icon: FPhosphorIcons.books,
                              label: 'Subjects in selected level',
                              count: activeSubjects,
                            ),
                            _StatRow(
                              icon: FPhosphorIcons.listNumbers,
                              label: 'Chapters in selected subject',
                              count: state.chapters.length,
                            ),
                            _StatRow(
                              icon: FPhosphorIcons.tag,
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
                              icon: FPhosphorIcons.graduationCap,
                              label: 'Education levels',
                              count: state.levels.length,
                            ),
                            _StatRow(
                              icon: FPhosphorIcons.buildings,
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
                    child: FSelect<String>.rich(
                      control: FSelectControl<String>.lifted(
                        value: state.selectedLevelId,
                        onChange: (value) {
                          if (value != null) cubit.selectLevel(value);
                        },
                      ),
                      label: const Text('Education Level'),
                      format: levelLabel,
                      children: [
                        for (final level in state.levels)
                          FSelectItem<String>(
                            title: Text(
                              '${level.nameEn} (${level.nameBn})',
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: level.id,
                          ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: 240,
                  child: FTextField(
                    control: FTextFieldControl.managed(
                      controller: searchController,
                      onChange: (value) => cubit.setSearchQuery(value.text),
                    ),
                    hint: 'Search Bangla, English, or code...',
                    prefixBuilder: (context, style, variants) =>
                        FTextField.prefixIconBuilder(
                          context,
                          style,
                          variants,
                          const Icon(FPhosphorIcons.magnifyingGlass, size: 16),
                        ),
                  ),
                ),
                FSwitch(
                  value: state.showArchived,
                  onChange: cubit.toggleShowArchived,
                  label: Text('Show Archived', style: typography.body.sm),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    FButton(
                      variant: state.activeTab == CurriculumTab.syllabus
                          ? .primary
                          : .outline,
                      size: .sm,
                      mainAxisSize: .min,
                      onPress: () => cubit.setTab(CurriculumTab.syllabus),
                      child: const Text('Subjects & Syllabus'),
                    ),
                    FButton(
                      variant: state.activeTab == CurriculumTab.boardsAndLevels
                          ? .primary
                          : .outline,
                      size: .sm,
                      mainAxisSize: .min,
                      onPress: () =>
                          cubit.setTab(CurriculumTab.boardsAndLevels),
                      child: const Text('Boards & Levels'),
                    ),
                  ],
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
    final typography = context.theme.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.secondary,
            shape: BoxShape.circle,
            border: Border.all(color: colors.border),
          ),
          child: Icon(icon, size: 14, color: colors.foreground),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: typography.body.sm.copyWith(
              color: colors.foreground,
              decoration: TextDecoration.underline,
              decorationColor: colors.border,
            ),
          ),
        ),
        Text(
          '$count',
          style: typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.foreground,
          ),
        ),
      ],
    );
  }
}
