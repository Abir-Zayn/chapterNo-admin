// Top controls bar for Curriculum Catalogue (level picker, search, archive, tab).
// Uses responsive Wrap so controls reflow cleanly on mobile and desktop widths.
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
    final cubit = context.read<CurriculumCubit>();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Curriculum Catalogue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              if (isReviewer) StatusBadge.neutral('Read-only (Reviewer)'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (state.levels.isNotEmpty)
                SizedBox(
                  width: 220,
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
        ],
      ),
    );
  }
}
