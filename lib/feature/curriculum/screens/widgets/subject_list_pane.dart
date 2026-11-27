// Subjects master column with Academic Group filter chips and CRUD actions.
// Renders Bangla titles in Hind Siliguri alongside NCTB and group badges.
import 'subject_list_pane_imports.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Subjects',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                if (canEdit)
                  FilledButton.tonalIcon(
                    onPressed: onAddSubject,
                    icon: const Icon(PhosphorIconsRegular.plus, size: 15),
                    label: const Text('Add Subject'),
                  ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('সকল', style: AppTypography.bangla(fontSize: 13)),
                  selected: selectedGroup == null,
                  onSelected: (_) => onSelectGroup(null),
                ),
                const SizedBox(width: 6),
                for (final group in AcademicGroup.values) ...[
                  ChoiceChip(
                    label: Text(
                      group.labelBn,
                      style: AppTypography.bangla(fontSize: 13),
                    ),
                    selected: selectedGroup == group,
                    onSelected: (_) => onSelectGroup(group),
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
                    icon: PhosphorIconsRegular.books,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTint : AppColors.canvas,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (subject.isArchived) StatusBadge.neutral('Archived'),
                if (canEdit)
                  PopupMenuButton<String>(
                    tooltip: 'Subject actions',
                    icon: const Icon(
                      PhosphorIconsRegular.dotsThreeVertical,
                      size: 16,
                    ),
                    onSelected: (action) {
                      if (action == 'edit') onEdit();
                      if (action == 'archive') onToggleArchive();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'archive',
                        child: Text(subject.isArchived ? 'Restore' : 'Archive'),
                      ),
                    ],
                  ),
              ],
            ),
            Text(
              subject.nameEn,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
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
