// Bulk Import page composing context picker, source panel, preview table,
// and submit panel behind a role guard (super_admin/editor only).
import 'imports/bulk_import_screen_imports.dart';

class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<BulkImportCubit>();
    if (cubit.state.status == BulkImportStatus.initial) {
      Future.microtask(cubit.loadContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.select(
      (AuthCubit cubit) => cubit.state.adminUser?.role ?? AdminRole.reviewer,
    );
    final canImport = role == AdminRole.superAdmin || role == AdminRole.editor;

    return BlocConsumer<BulkImportCubit, BulkImportState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          showAppErrorSnackBar(
            context,
            message: state.errorMessage!,
            statusCode: state.errorStatusCode,
          );
        }
      },
      builder: (context, state) {
        if (state.status == BulkImportStatus.initial ||
            state.status == BulkImportStatus.loading) {
          return const AppLoadingView(message: 'Loading import workspace…');
        }
        if (state.status == BulkImportStatus.error && state.levels.isEmpty) {
          return AppErrorScene(
            statusCode: state.errorStatusCode,
            message: state.errorMessage ?? 'Failed to load import context.',
            onRetry: () => context.read<BulkImportCubit>().loadContext(),
            onSignOut: () => context.read<AuthCubit>().signOut(),
          );
        }
        if (!canImport) {
          return AppEmptyView(
            title: 'Read-Only Access',
            subtitle:
                'Your reviewer role can browse the curriculum and question '
                'bank, but bulk MCQ imports are limited to super admins and '
                'editors.',
            icon: FPhosphorIcons.shieldWarning,
          );
        }
        final colors = context.theme.colors;
        final typography = context.theme.typography;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bulk CSV / JSON Importer',
              style: typography.body.xl2.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Import MCQ rows from Google Sheets or Gemini exports into the '
              'selected subject — validated locally before touching the '
              'database.',
              style: typography.body.sm.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: 14),
            BulkImportContextPicker(
              levels: state.levels,
              subjects: state.subjects,
              chapters: state.activeChapters,
              boards: state.boardsForLevel,
              selectedLevelId: state.selectedLevelId,
              selectedSubjectId: state.selectedSubjectId,
              selectedChapterId: state.selectedChapterId,
              selectedBoardId: state.selectedBoardId,
              isLoadingChapters: state.isLoadingChapters,
              onSelectLevel: context.read<BulkImportCubit>().selectLevel,
              onSelectSubject: context.read<BulkImportCubit>().selectSubject,
              onSelectChapter: context.read<BulkImportCubit>().selectChapter,
              onSelectBoard: context.read<BulkImportCubit>().selectBoard,
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              AppErrorBanner(
                message: state.errorMessage ?? '',
                onDismiss: () => context.read<BulkImportCubit>().clearError(),
              ),
            ],
            if (state.encodingWarning != null) ...[
              const SizedBox(height: 12),
              _EncodingWarningBanner(message: state.encodingWarning),
            ],
            const SizedBox(height: 12),
            BulkImportSourcePanel(
              inputMode: state.inputMode,
              sourceName: state.sourceName,
              sourceText: state.sourceText,
              canImport: !state.isSubmitting,
              onSetInputMode: context.read<BulkImportCubit>().setInputMode,
              onUpdateSourceText: context
                  .read<BulkImportCubit>()
                  .updateSourceText,
              onParseSourceText: context
                  .read<BulkImportCubit>()
                  .parseSourceText,
              onIngestFile: context.read<BulkImportCubit>().ingestFile,
              onClearSource: context.read<BulkImportCubit>().clearSource,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: BulkImportPreviewTable(
                rows: state.visibleRows,
                totalRows: state.totalRows,
                validRowCount: state.validRowCount,
                errorRowCount: state.errorRowCount,
                rowFilter: state.rowFilter,
                onSetRowFilter: context.read<BulkImportCubit>().setRowFilter,
              ),
            ),
            const SizedBox(height: 14),
            BulkImportSubmitPanel(
              canImport: canImport,
              validRowCount: state.validRowCount,
              isSubmitting: state.isSubmitting,
              submitChunksDone: state.submitChunksDone,
              submitChunksTotal: state.submitChunksTotal,
              submitPhase: state.submitPhase,
              summary: state.summary,
              onSubmit: () => context.read<BulkImportCubit>().submitValidRows(),
            ),
          ],
        );
      },
    );
  }
}

class _EncodingWarningBanner extends StatelessWidget {
  final String? message;

  const _EncodingWarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return FAlert(
      icon: const Icon(FPhosphorIcons.warningCircle),
      title: Text(message ?? ''),
    );
  }
}
