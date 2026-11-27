// Boards & Education Levels management tab (mutations gated to super_admin).
// Responsive two-pane layout on desktop, stacked on mobile screens.
import 'imports/boards_levels_tab_imports.dart';

class BoardsLevelsTab extends StatelessWidget {
  const BoardsLevelsTab({
    super.key,
    required this.levels,
    required this.boards,
    required this.selectedLevelId,
    required this.canMutateLevelsAndBoards,
    required this.onSelectLevel,
    required this.onAddLevel,
    required this.onEditLevel,
    required this.onToggleLevelArchive,
    required this.onAddBoard,
    required this.onEditBoard,
    required this.onToggleBoardArchive,
  });

  final List<EducationLevel> levels;
  final List<Board> boards;
  final String? selectedLevelId;
  final bool canMutateLevelsAndBoards;
  final ValueChanged<String> onSelectLevel;
  final VoidCallback onAddLevel;
  final ValueChanged<EducationLevel> onEditLevel;
  final ValueChanged<EducationLevel> onToggleLevelArchive;
  final VoidCallback onAddBoard;
  final ValueChanged<Board> onEditBoard;
  final ValueChanged<Board> onToggleBoardArchive;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final levelsCard = _LevelsCard(
      levels: levels,
      selectedLevelId: selectedLevelId,
      canMutate: canMutateLevelsAndBoards,
      onSelect: onSelectLevel,
      onAdd: onAddLevel,
      onEdit: onEditLevel,
      onToggleArchive: onToggleLevelArchive,
    );
    final boardsCard = _BoardsCard(
      boards: boards,
      hasSelectedLevel: selectedLevelId != null,
      canMutate: canMutateLevelsAndBoards,
      onAdd: onAddBoard,
      onEdit: onEditBoard,
      onToggleArchive: onToggleBoardArchive,
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 4, child: levelsCard),
          const SizedBox(width: 16),
          Expanded(flex: 6, child: boardsCard),
        ],
      );
    }

    return Column(
      children: [
        Expanded(child: levelsCard),
        const SizedBox(height: 12),
        Expanded(child: boardsCard),
      ],
    );
  }
}

class _LevelsCard extends StatelessWidget {
  const _LevelsCard({
    required this.levels,
    required this.selectedLevelId,
    required this.canMutate,
    required this.onSelect,
    required this.onAdd,
    required this.onEdit,
    required this.onToggleArchive,
  });

  final List<EducationLevel> levels;
  final String? selectedLevelId;
  final bool canMutate;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<EducationLevel> onEdit;
  final ValueChanged<EducationLevel> onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Education Levels',
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canMutate)
                  FButton(
                    variant: .outline,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: onAdd,
                    prefix: const Icon(FPhosphorIcons.plus, size: 15),
                    child: const Text('Add Level'),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: levels.isEmpty
                ? const AppEmptyView(
                    title: 'No education levels',
                    subtitle: 'Create an education level such as SSC or HSC.',
                    icon: FPhosphorIcons.graduationCap,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: levels.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final isSelected = level.id == selectedLevelId;
                      return FTappable(
                        onPress: () => onSelect(level.id),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.secondary
                                : colors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level.nameBn,
                                      style: AppTypography.bangla(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${level.nameEn} (${level.code})',
                                      style: typography.body.xs.copyWith(
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (level.isArchived)
                                StatusBadge.neutral('Archived'),
                              if (canMutate)
                                FPopoverMenu(
                                  semanticsLabel: 'Education level actions',
                                  menuBuilder: (context, controller, _) => [
                                    FItemGroup(
                                      children: [
                                        FItem(
                                          title: const Text('Edit'),
                                          onPress: () {
                                            controller.hide();
                                            onEdit(level);
                                          },
                                        ),
                                        FItem(
                                          title: Text(
                                            level.isArchived
                                                ? 'Restore'
                                                : 'Archive',
                                          ),
                                          onPress: () {
                                            controller.hide();
                                            onToggleArchive(level);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                  builder: (context, controller, _) =>
                                      FButton.icon(
                                        variant: .ghost,
                                        size: .xs,
                                        semanticsLabel:
                                            'Education level actions',
                                        onPress: controller.toggle,
                                        child: const Icon(
                                          FPhosphorIcons.dotsThreeVertical,
                                          size: 16,
                                        ),
                                      ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BoardsCard extends StatelessWidget {
  const _BoardsCard({
    required this.boards,
    required this.hasSelectedLevel,
    required this.canMutate,
    required this.onAdd,
    required this.onEdit,
    required this.onToggleArchive,
  });

  final List<Board> boards;
  final bool hasSelectedLevel;
  final bool canMutate;
  final VoidCallback onAdd;
  final ValueChanged<Board> onEdit;
  final ValueChanged<Board> onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Education Boards',
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canMutate && hasSelectedLevel)
                  FButton(
                    variant: .outline,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: onAdd,
                    prefix: const Icon(FPhosphorIcons.plus, size: 15),
                    child: const Text('Add Board'),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: !hasSelectedLevel
                ? const AppEmptyView(
                    title: 'Select an education level',
                    subtitle: 'Choose a level to view or manage boards.',
                    icon: FPhosphorIcons.buildings,
                  )
                : boards.isEmpty
                ? const AppEmptyView(
                    title: 'No boards found',
                    subtitle: 'Add Bangladesh education boards for this level.',
                    icon: FPhosphorIcons.buildings,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: boards.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final board = boards[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    board.nameBn,
                                    style: AppTypography.bangla(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${board.nameEn} (${board.code})',
                                    style: typography.body.xs.copyWith(
                                      color: colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (board.isArchived)
                              StatusBadge.neutral('Archived'),
                            if (canMutate)
                              FPopoverMenu(
                                semanticsLabel: 'Education board actions',
                                menuBuilder: (context, controller, _) => [
                                  FItemGroup(
                                    children: [
                                      FItem(
                                        title: const Text('Edit'),
                                        onPress: () {
                                          controller.hide();
                                          onEdit(board);
                                        },
                                      ),
                                      FItem(
                                        title: Text(
                                          board.isArchived
                                              ? 'Restore'
                                              : 'Archive',
                                        ),
                                        onPress: () {
                                          controller.hide();
                                          onToggleArchive(board);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                                builder: (context, controller, _) =>
                                    FButton.icon(
                                      variant: .ghost,
                                      size: .xs,
                                      semanticsLabel: 'Education board actions',
                                      onPress: controller.toggle,
                                      child: const Icon(
                                        FPhosphorIcons.dotsThreeVertical,
                                        size: 16,
                                      ),
                                    ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
