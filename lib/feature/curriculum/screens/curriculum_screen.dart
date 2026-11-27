// Curriculum Catalogue page composing top bar, boards/levels, and syllabus.
// Delegates dialog/archive actions to utils and panes to widgets/.
import 'imports/curriculum_screen_imports.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<CurriculumCubit>();
    if (cubit.state.status == CurriculumStatus.initial) {
      cubit.loadInitial();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select(
      (AuthCubit cubit) => cubit.state.adminUser?.role ?? AdminRole.reviewer,
    );
    final isReviewer = role == AdminRole.reviewer;
    final canEditSyllabus =
        role == AdminRole.superAdmin || role == AdminRole.editor;
    final canMutateLevelsAndBoards = role == AdminRole.superAdmin;

    return BlocBuilder<CurriculumCubit, CurriculumState>(
      builder: (context, state) {
        if (state.status == CurriculumStatus.loading ||
            state.status == CurriculumStatus.initial) {
          return const AppLoadingView(
            message: 'Loading Curriculum Catalogue...',
          );
        }

        if (state.status == CurriculumStatus.error && state.levels.isEmpty) {
          return AppEmptyView(
            title: 'Failed to load curriculum',
            subtitle: state.errorMessage ?? 'Unable to reach GraphQL API.',
            icon: PhosphorIconsRegular.warningCircle,
            action: FilledButton.icon(
              onPressed: () => context.read<CurriculumCubit>().loadInitial(),
              icon: const Icon(PhosphorIconsRegular.arrowClockwise, size: 16),
              label: const Text('Retry'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CurriculumTopBar(
              state: state,
              searchController: _searchController,
              isReviewer: isReviewer,
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              AppErrorBanner(
                message: state.errorMessage!,
                onDismiss: () => context.read<CurriculumCubit>().clearError(),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: state.activeTab == CurriculumTab.boardsAndLevels
                  ? BoardsLevelsTab(
                      levels: state.visibleLevels,
                      boards: state.visibleBoards,
                      selectedLevelId: state.selectedLevelId,
                      canMutateLevelsAndBoards: canMutateLevelsAndBoards,
                      onSelectLevel: (id) =>
                          context.read<CurriculumCubit>().selectLevel(id),
                      onAddLevel: () => CurriculumDialogActions.openLevelDialog(
                        context,
                        state,
                      ),
                      onEditLevel: (level) =>
                          CurriculumDialogActions.openLevelDialog(
                            context,
                            state,
                            level: level,
                          ),
                      onToggleLevelArchive: (level) =>
                          CurriculumDialogActions.confirmArchive(
                            context,
                            kind: CurriculumNodeKind.educationLevel,
                            id: level.id,
                            name: level.nameEn,
                            currentlyActive: level.isActive,
                          ),
                      onAddBoard: () => CurriculumDialogActions.openBoardDialog(
                        context,
                        state,
                      ),
                      onEditBoard: (board) =>
                          CurriculumDialogActions.openBoardDialog(
                            context,
                            state,
                            board: board,
                          ),
                      onToggleBoardArchive: (board) =>
                          CurriculumDialogActions.confirmArchive(
                            context,
                            kind: CurriculumNodeKind.board,
                            id: board.id,
                            name: board.nameEn,
                            currentlyActive: board.isActive,
                          ),
                    )
                  : CurriculumSyllabusView(
                      state: state,
                      canEditSyllabus: canEditSyllabus,
                      canDeleteTopic: canMutateLevelsAndBoards,
                    ),
            ),
          ],
        );
      },
    );
  }
}
