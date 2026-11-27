// Sticky bulk moderation bar displayed when one or more MCQs are selected.
// Enforces role-based actions (reviewer/super_admin vs editor).
import 'imports/question_bank_bulk_bar_imports.dart';

class QuestionBankBulkBar extends StatelessWidget {
  const QuestionBankBulkBar({
    super.key,
    required this.selectedCount,
    required this.role,
    required this.isModerating,
    required this.onApplyAction,
    required this.onClearSelection,
  });

  final int selectedCount;
  final AdminRole role;
  final bool isModerating;
  final ValueChanged<QuestionBankModerationAction> onApplyAction;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final canPublish = QuestionBankPermissions.canPublish(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.primary.withValues(alpha: 0.45)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FPhosphorIcons.checkSquare, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                '$selectedCount selected',
                style: context.theme.typography.body.sm.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              FButton(
                variant: .ghost,
                size: .sm,
                mainAxisSize: .min,
                onPress: isModerating ? null : onClearSelection,
                child: const Text('Clear'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (canPublish) ...[
                FButton(
                  mainAxisSize: .min,
                  onPress: isModerating
                      ? null
                      : () => onApplyAction(
                          QuestionBankModerationAction.approveAndPublish,
                        ),
                  prefix: isModerating
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primaryForeground,
                          ),
                        )
                      : const Icon(FPhosphorIcons.checkCircle, size: 16),
                  child: const Text('Approve & Publish'),
                ),
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: isModerating
                      ? null
                      : () => onApplyAction(
                          QuestionBankModerationAction.sendToDraft,
                        ),
                  prefix: const Icon(FPhosphorIcons.notePencil, size: 15),
                  child: const Text('Move to Draft'),
                ),
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: isModerating
                      ? null
                      : () =>
                            onApplyAction(QuestionBankModerationAction.archive),
                  prefix: const Icon(FPhosphorIcons.archive, size: 15),
                  child: const Text('Archive'),
                ),
              ] else ...[
                FButton(
                  mainAxisSize: .min,
                  onPress: isModerating
                      ? null
                      : () => onApplyAction(
                          QuestionBankModerationAction.submitForReview,
                        ),
                  prefix: const Icon(FPhosphorIcons.paperPlaneRight, size: 16),
                  child: const Text('Submit for Review'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
