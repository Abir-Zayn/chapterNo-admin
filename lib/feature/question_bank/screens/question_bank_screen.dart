// Question Bank Browser screen composing search/filters, bulk moderation bar,
// paginated MCQ list, and inspection modal with role-aware controls.
import 'imports/question_bank_screen_imports.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<QuestionBankCubit>();
    if (cubit.state.status == QuestionBankLoadStatus.initial) {
      Future.microtask(cubit.initialize);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select(
      (AuthCubit cubit) => cubit.state.adminUser?.role ?? AdminRole.reviewer,
    );

    return BlocConsumer<QuestionBankCubit, QuestionBankState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.feedbackMessage != current.feedbackMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          showAppErrorSnackBar(
            context,
            message: state.errorMessage!,
            statusCode: state.errorStatusCode,
          );
        }
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.feedbackMessage!)));
          context.read<QuestionBankCubit>().clearFeedback();
        }
      },
      builder: (context, state) {
        if (state.status == QuestionBankLoadStatus.initial ||
            state.status == QuestionBankLoadStatus.loading) {
          return const AppLoadingView(message: 'Loading question bank…');
        }
        if (state.status == QuestionBankLoadStatus.error &&
            state.items.isEmpty &&
            state.levels.isEmpty) {
          return AppErrorScene(
            statusCode: state.errorStatusCode,
            message: state.errorMessage ?? 'Failed to load question bank.',
            onRetry: () => context.read<QuestionBankCubit>().initialize(),
            onSignOut: () => context.read<AuthCubit>().signOut(),
          );
        }

        final cubit = context.read<QuestionBankCubit>();
        final colors = context.theme.colors;
        final typography = context.theme.typography;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question Bank Browser',
              style: typography.body.lg.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search, filter, inspect rendered Bangla & LaTeX MCQs, and '
              'approve or archive questions for the Student App.',
              style: typography.body.sm.copyWith(
                fontSize: 12.5,
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 14),
            QuestionBankFilterBar(
              levels: state.levels,
              subjects: state.subjects,
              chapters: state.activeChapters,
              topics: state.topicsForSelectedChapter,
              boards: state.boardsForLevel,
              selectedLevelId: state.selectedLevelId,
              filter: state.filter,
              totalCount: state.totalCount,
              isLoadingChapters: state.isLoadingChapters,
              isFetching: state.isFetchingPage,
              onSearchChanged: cubit.updateSearchQuery,
              onSelectLevel: cubit.selectLevel,
              onSelectSubject: cubit.selectSubject,
              onSelectChapter: cubit.selectChapter,
              onSelectTopic: cubit.selectTopic,
              onSelectBoard: cubit.selectBoard,
              onSelectStatus: cubit.selectStatus,
              onSelectSourceType: cubit.selectSourceType,
              onSelectDifficulty: cubit.selectDifficulty,
              onSelectRightsStatus: cubit.selectRightsStatus,
              onSetExamYear: cubit.setExamYear,
              onClearAll: cubit.clearAllFilters,
              onRefresh: cubit.fetchCurrentPage,
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 10),
              AppErrorBanner(
                message: state.errorMessage!,
                onDismiss: cubit.clearError,
              ),
            ],
            if (state.selectedIds.isNotEmpty) ...[
              const SizedBox(height: 10),
              QuestionBankBulkBar(
                selectedCount: state.selectedIds.length,
                role: role,
                isModerating: state.isModerating,
                onApplyAction: (action) => cubit.applyModeration(
                  questionIds: state.selectedIds.toList(),
                  action: action,
                ),
                onClearSelection: cubit.clearSelection,
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: QuestionBankListView(
                items: state.items,
                totalCount: state.totalCount,
                page: state.filter.page,
                totalPages: state.totalPages,
                showingFrom: state.showingFrom,
                showingTo: state.showingTo,
                selectedIds: state.selectedIds,
                role: role,
                isFetching: state.isFetchingPage,
                isModerating: state.isModerating,
                chapterLabelsById: state.chapterLabelsById,
                boardLabelsById: state.boardLabelsById,
                onToggleSelect: cubit.toggleSelection,
                onToggleSelectAll: cubit.toggleSelectAll,
                onInspectQuestion: (question) => _openDetailDialog(
                  context,
                  question: question,
                  role: role,
                  state: state,
                ),
                onQuickAction: (question, action) => cubit.applyModeration(
                  questionIds: [question.id],
                  action: action,
                ),
                onGoToPage: cubit.goToPage,
              ),
            ),
          ],
        );
      },
    );
  }

  void _openDetailDialog(
    BuildContext context, {
    required McqQuestion question,
    required AdminRole role,
    required QuestionBankState state,
  }) {
    final cubit = context.read<QuestionBankCubit>();
    showFDialog<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context, style, animation) {
        final screenSize = MediaQuery.sizeOf(context);
        final dialogWidth = screenSize.width < 680
            ? screenSize.width - 24
            : 660.0;
        return FDialog(
          style: style,
          animation: animation,
          clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: screenSize.height * 0.88,
          ),
          builder: (_, _) => QuestionDetailDialog(
            question: question,
            role: role,
            subjectLabel: state.subjectLabelsById[question.subjectId],
            chapterLabel: state.chapterLabelsById[question.chapterId],
            boardLabel: question.boardId == null
                ? null
                : state.boardLabelsById[question.boardId],
            onApplyAction: (action) => cubit.applyModeration(
              questionIds: [question.id],
              action: action,
            ),
          ),
        );
      },
    );
  }
}
