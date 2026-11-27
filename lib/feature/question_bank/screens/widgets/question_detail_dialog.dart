// Modal dialog inspecting an MCQ with rendered LaTeX options, answer key,
// explanation, provenance metadata, and role-aware moderation actions.
import 'imports/question_detail_dialog_imports.dart';

class QuestionDetailDialog extends StatelessWidget {
  const QuestionDetailDialog({
    super.key,
    required this.question,
    required this.role,
    required this.subjectLabel,
    required this.chapterLabel,
    required this.boardLabel,
    required this.onApplyAction,
  });

  final McqQuestion question;
  final AdminRole role;
  final String? subjectLabel;
  final String? chapterLabel;
  final String? boardLabel;
  final Future<bool> Function(QuestionBankModerationAction action)
  onApplyAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: colors.muted,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(bottom: BorderSide(color: colors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.externalCode ?? 'MCQ Detail',
                      style: typography.body.sm.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${question.questionType.label} · v${question.version} · '
                      '${question.status.label}'
                      '${question.isVerified ? ' · Verified' : ''}',
                      style: typography.body.sm.copyWith(
                        fontSize: 12,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              FTooltip(
                tipBuilder: (_, _) => const Text('Close'),
                child: FButton(
                  variant: .ghost,
                  size: .sm,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(),
                  child: const Icon(FPhosphorIcons.x, size: 18),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (subjectLabel != null)
                      StatusBadge.neutral(subjectLabel!),
                    if (chapterLabel != null)
                      StatusBadge.neutral(chapterLabel!),
                    if (boardLabel != null) StatusBadge.neutral(boardLabel!),
                    StatusBadge.neutral(question.difficulty.label),
                    StatusBadge.neutral(
                      question.examYear != null
                          ? '${question.sourceType.label} · ${question.examYear}'
                          : question.sourceType.label,
                    ),
                    StatusBadge.neutral(question.rightsStatus.label),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Question',
                  style: typography.body.sm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 6),
                SharedMathPreviewText(
                  text: question.title,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
                if (question.statements.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.muted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < question.statements.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: SharedMathPreviewText(
                              text:
                                  '${_romanNumeral(i + 1)}. ${question.statements[i]}',
                              fontSize: 13.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Options',
                  style: typography.body.sm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                for (final option in question.options) ...[
                  _OptionTile(
                    option: option,
                    isCorrect: option.key == question.correctOption,
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
                Text(
                  'Explanation',
                  style: typography.body.sm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.muted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: question.explanation == null
                      ? Text(
                          'No explanation provided yet.',
                          style: typography.body.sm.copyWith(
                            fontSize: 13,
                            color: colors.mutedForeground,
                          ),
                        )
                      : SharedMathPreviewText(
                          text: question.explanation!,
                          fontSize: 14,
                        ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: colors.muted,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: _buildActionButtons(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final actions = <Widget>[];

    Future<void> runAction(QuestionBankModerationAction action) async {
      final ok = await onApplyAction(action);
      if (ok && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    if (QuestionBankPermissions.canPerformAction(
      role: role,
      question: question,
      action: QuestionBankModerationAction.approveAndPublish,
    )) {
      actions.add(
        FButton(
          mainAxisSize: .min,
          onPress: () =>
              runAction(QuestionBankModerationAction.approveAndPublish),
          prefix: const Icon(FPhosphorIcons.checkCircle, size: 16),
          child: const Text('Approve & Publish'),
        ),
      );
    }

    if (QuestionBankPermissions.canPerformAction(
      role: role,
      question: question,
      action: QuestionBankModerationAction.submitForReview,
    )) {
      actions.add(
        FButton(
          mainAxisSize: .min,
          onPress: () =>
              runAction(QuestionBankModerationAction.submitForReview),
          prefix: const Icon(FPhosphorIcons.paperPlaneRight, size: 16),
          child: const Text('Submit for Review'),
        ),
      );
    }

    if (QuestionBankPermissions.canPerformAction(
      role: role,
      question: question,
      action: QuestionBankModerationAction.sendToDraft,
    )) {
      actions.add(
        FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () => runAction(QuestionBankModerationAction.sendToDraft),
          prefix: const Icon(FPhosphorIcons.notePencil, size: 15),
          child: const Text('Send to Draft'),
        ),
      );
    }

    if (QuestionBankPermissions.canPerformAction(
      role: role,
      question: question,
      action: QuestionBankModerationAction.archive,
    )) {
      actions.add(
        FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () => runAction(QuestionBankModerationAction.archive),
          prefix: const Icon(FPhosphorIcons.archive, size: 15),
          child: const Text('Archive'),
        ),
      );
    }

    if (QuestionBankPermissions.canPerformAction(
      role: role,
      question: question,
      action: QuestionBankModerationAction.restore,
    )) {
      actions.add(
        FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () => runAction(QuestionBankModerationAction.restore),
          prefix: const Icon(FPhosphorIcons.arrowCounterClockwise, size: 15),
          child: const Text('Restore'),
        ),
      );
    }

    if (QuestionBankPermissions.canPerformAction(
      role: role,
      question: question,
      action: QuestionBankModerationAction.deletePermanently,
    )) {
      actions.add(
        FButton(
          variant: .destructive,
          mainAxisSize: .min,
          onPress: () async {
            final confirmed = await showFDialog<bool>(
              context: context,
              useRootNavigator: true,
              useSafeArea: true,
              builder: (context, style, animation) => FDialog(
                style: style,
                animation: animation,
                builder: (context, style) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: DefaultTextStyle.merge(
                          style: style.titleTextStyle,
                          child: const Text('Delete Question Permanently?'),
                        ),
                      ),
                      DefaultTextStyle.merge(
                        style: style.bodyTextStyle,
                        child: Text(
                          'This will permanently remove ${question.externalCode ?? question.id}. '
                          'Consider archiving instead if students may have referenced it.',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.end,
                        children: [
                          FButton(
                            variant: .outline,
                            mainAxisSize: .min,
                            onPress: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FButton(
                            variant: .destructive,
                            mainAxisSize: .min,
                            onPress: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (confirmed == true) {
              await runAction(QuestionBankModerationAction.deletePermanently);
            }
          },
          prefix: const Icon(FPhosphorIcons.trash, size: 15),
          child: const Text('Delete'),
        ),
      );
    }

    return actions;
  }

  String _romanNumeral(int n) {
    const numerals = ['i', 'ii', 'iii', 'iv', 'v'];
    if (n >= 1 && n <= numerals.length) return numerals[n - 1];
    return '$n';
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option, required this.isCorrect});

  final McqOption option;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final dark = colors.brightness == Brightness.dark;
    final successBackground = dark
        ? const Color(0xFF0F291A)
        : const Color(0xFFF0FDF4);
    final successForeground = dark
        ? const Color(0xFF4ADE80)
        : const Color(0xFF16A34A);
    final successBorder = dark
        ? const Color(0xFF166534)
        : const Color(0xFFBBF7D0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect ? successBackground : colors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? successBorder : colors.border,
          width: isCorrect ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCorrect ? successForeground : colors.muted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              option.key,
              style: context.theme.typography.body.sm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isCorrect ? successBackground : colors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SharedMathPreviewText(text: option.text, fontSize: 14),
          ),
          if (isCorrect)
            Icon(
              FPhosphorIcons.checkCircle,
              size: 18,
              color: successForeground,
            ),
        ],
      ),
    );
  }
}
