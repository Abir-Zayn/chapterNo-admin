// Subjects master column with Academic Group filter buttons and CRUD actions.
// Renders Bangla titles in Hind Siliguri alongside NCTB and group badges.
import 'imports/subject_list_pane_imports.dart';

class SubjectListPane extends StatelessWidget {
  const SubjectListPane({
    super.key,
    required this.subjects,
    required this.selectedSubjectId,
    required this.selectedGroup,
    required this.isLoading,
    required this.canEdit,
    required this.onSelectGroup,
    required this.onSelectSubject,
    required this.onAddSubject,
    required this.onEditSubject,
    required this.onToggleArchive,
  });

  final List<Subject> subjects;
  final String? selectedSubjectId;
  final AcademicGroup? selectedGroup;
  final bool isLoading;
  final bool canEdit;
  final ValueChanged<AcademicGroup?> onSelectGroup;
  final ValueChanged<String> onSelectSubject;
  final VoidCallback onAddSubject;
  final ValueChanged<Subject> onEditSubject;
  final ValueChanged<Subject> onToggleArchive;

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
                    'Subjects',
                    style: typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (canEdit)
                  FButton(
                    variant: .outline,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: onAddSubject,
                    prefix: const Icon(FPhosphorIcons.plus, size: 15),
                    child: const Text('Add Subject'),
                  ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                FButton(
                  variant: selectedGroup == null ? .primary : .outline,
                  size: .sm,
                  mainAxisSize: .min,
                  onPress: () => onSelectGroup(null),
                  child: Text(
                    'সকল',
                    style: AppTypography.bangla(
                      fontSize: 13,
                      fontWeight: selectedGroup == null
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: selectedGroup == null
                          ? colors.primaryForeground
                          : colors.foreground,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                for (final group in AcademicGroup.values) ...[
                  FButton(
                    variant: selectedGroup == group ? .primary : .outline,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: () => onSelectGroup(group),
                    child: Text(
                      group.labelBn,
                      style: AppTypography.bangla(
                        fontSize: 13,
                        fontWeight: selectedGroup == group
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: selectedGroup == group
                            ? colors.primaryForeground
                            : colors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: isLoading
                ? const AppLoadingView(message: 'Loading subjects...')
                : subjects.isEmpty
                ? const AppEmptyView(
                    title: 'No subjects found',
                    subtitle: 'Adjust filters or add a subject for this level.',
                    icon: FPhosphorIcons.books,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: subjects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      final isSelected = subject.id == selectedSubjectId;
                      return _SubjectTile(
                        subject: subject,
                        isSelected: isSelected,
                        canEdit: canEdit,
                        onTap: () => onSelectSubject(subject.id),
                        onEdit: () => onEditSubject(subject),
                        onToggleArchive: () => onToggleArchive(subject),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.subject,
    required this.isSelected,
    required this.canEdit,
    required this.onTap,
    required this.onEdit,
    required this.onToggleArchive,
  });

  final Subject subject;
  final bool isSelected;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return FTappable(
      onPress: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? colors.secondary : colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject.nameBn,
                    style: AppTypography.bangla(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.primary : colors.foreground,
                    ),
                  ),
                ),
                if (subject.isArchived) StatusBadge.neutral('Archived'),
                if (canEdit)
                  FPopoverMenu(
                    semanticsLabel: 'Subject actions',
                    menuBuilder: (context, controller, _) => [
                      FItemGroup(
                        children: [
                          FItem(
                            title: const Text('Edit'),
                            onPress: () {
                              controller.hide();
                              onEdit();
                            },
                          ),
                          FItem(
                            title: Text(
                              subject.isArchived ? 'Restore' : 'Archive',
                            ),
                            onPress: () {
                              controller.hide();
                              onToggleArchive();
                            },
                          ),
                        ],
                      ),
                    ],
                    builder: (context, controller, _) => FButton.icon(
                      variant: .ghost,
                      size: .xs,
                      semanticsLabel: 'Subject actions',
                      semanticsTooltip: 'Subject actions',
                      onPress: controller.toggle,
                      child: const Icon(
                        FPhosphorIcons.dotsThreeVertical,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              subject.nameEn,
              style: typography.body.xs.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                StatusBadge.neutral(subject.academicGroup.labelBn),
                if (subject.nctbCode != null && subject.nctbCode!.isNotEmpty)
                  StatusBadge.neutral('NCTB ${subject.nctbCode}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
