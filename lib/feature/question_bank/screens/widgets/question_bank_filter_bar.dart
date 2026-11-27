// Responsive search and multi-axis filter bar for the Question Bank Browser.
// Wraps cleanly across desktop and mobile viewports with collapsible filters.
import 'imports/question_bank_filter_bar_imports.dart';

class QuestionBankFilterBar extends StatefulWidget {
  const QuestionBankFilterBar({
    super.key,
    required this.levels,
    required this.subjects,
    required this.chapters,
    required this.topics,
    required this.boards,
    required this.selectedLevelId,
    required this.filter,
    required this.totalCount,
    required this.isLoadingChapters,
    required this.isFetching,
    required this.onSearchChanged,
    required this.onSelectLevel,
    required this.onSelectSubject,
    required this.onSelectChapter,
    required this.onSelectTopic,
    required this.onSelectBoard,
    required this.onSelectStatus,
    required this.onSelectSourceType,
    required this.onSelectDifficulty,
    required this.onSelectRightsStatus,
    required this.onSetExamYear,
    required this.onClearAll,
    required this.onRefresh,
  });

  final List<EducationLevel> levels;
  final List<Subject> subjects;
  final List<Chapter> chapters;
  final List<Topic> topics;
  final List<Board> boards;
  final String? selectedLevelId;
  final QuestionBankFilter filter;
  final int totalCount;
  final bool isLoadingChapters;
  final bool isFetching;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSelectLevel;
  final ValueChanged<int?> onSelectSubject;
  final ValueChanged<int?> onSelectChapter;
  final ValueChanged<int?> onSelectTopic;
  final ValueChanged<String?> onSelectBoard;
  final ValueChanged<McqStatus?> onSelectStatus;
  final ValueChanged<McqSourceType?> onSelectSourceType;
  final ValueChanged<McqDifficulty?> onSelectDifficulty;
  final ValueChanged<McqRightsStatus?> onSelectRightsStatus;
  final ValueChanged<int?> onSetExamYear;
  final VoidCallback onClearAll;
  final VoidCallback onRefresh;

  @override
  State<QuestionBankFilterBar> createState() => _QuestionBankFilterBarState();
}

class _QuestionBankFilterBarState extends State<QuestionBankFilterBar> {
  late final TextEditingController _searchController;
  late final TextEditingController _yearController;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filter.searchQuery);
    _yearController = TextEditingController(
      text: widget.filter.examYear?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant QuestionBankFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter.searchQuery.isEmpty &&
        _searchController.text.isNotEmpty) {
      _searchController.clear();
    }
    if (widget.filter.examYear == null && _yearController.text.isNotEmpty) {
      _yearController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 720;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: isNarrow ? double.infinity : 300,
                  child: FTextField(
                    control: FTextFieldControl.managed(
                      controller: _searchController,
                      onChange: (value) => widget.onSearchChanged(value.text),
                    ),
                    hint: 'Search title or external_code…',
                    prefixBuilder: (context, style, variants) =>
                        FTextField.prefixIconBuilder(
                          context,
                          style,
                          variants,
                          const Icon(FPhosphorIcons.magnifyingGlass, size: 17),
                        ),
                    clearable: (value) => value.text.isNotEmpty,
                    clearIconBuilder: (context, style, clear) => FTooltip(
                      tipBuilder: (_, _) => const Text('Clear search'),
                      child: FButton(
                        style: style.clearButtonStyle,
                        onPress: () {
                          clear();
                          widget.onSearchChanged('');
                          setState(() {});
                        },
                        child: const Icon(FPhosphorIcons.x, size: 15),
                      ),
                    ),
                  ),
                ),
                _buildDropdown<McqStatus?>(
                  width: 145,
                  label: 'Status',
                  value: widget.filter.status,
                  items: {
                    null: 'All statuses',
                    for (final status in McqStatus.values) status: status.label,
                  },
                  onChanged: widget.onSelectStatus,
                ),
                _buildDropdown<int?>(
                  width: 175,
                  label: 'Subject',
                  value: widget.filter.subjectId,
                  items: {
                    null: 'All subjects',
                    for (final subject in widget.subjects)
                      if (int.tryParse(subject.id) != null)
                        int.parse(subject.id): subject.nameBn.isNotEmpty
                            ? subject.nameBn
                            : subject.nameEn,
                  },
                  onChanged: widget.onSelectSubject,
                ),
                _buildDropdown<int?>(
                  width: 185,
                  label: widget.isLoadingChapters ? 'Loading…' : 'Chapter',
                  value: widget.filter.chapterId,
                  items: {
                    null: 'All chapters',
                    for (final chapter in widget.chapters)
                      if (int.tryParse(chapter.id) != null)
                        int.parse(chapter.id):
                            '${chapter.code} · ${chapter.nameBn}',
                  },
                  onChanged: widget.filter.subjectId == null
                      ? null
                      : widget.onSelectChapter,
                ),
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => setState(() => _showAdvanced = !_showAdvanced),
                  prefix: Icon(
                    _showAdvanced
                        ? FPhosphorIcons.funnelSimpleX
                        : FPhosphorIcons.funnelSimple,
                    size: 16,
                  ),
                  child: Text(_showAdvanced ? 'Less filters' : 'More filters'),
                ),
                if (widget.filter.hasActiveFilters)
                  FButton(
                    variant: .ghost,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: widget.onClearAll,
                    prefix: const Icon(
                      FPhosphorIcons.arrowCounterClockwise,
                      size: 15,
                    ),
                    child: const Text('Clear'),
                  ),
                FTooltip(
                  tipBuilder: (_, _) => const Text('Refresh questions'),
                  child: FButton(
                    variant: .ghost,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: widget.isFetching ? null : widget.onRefresh,
                    child: const Icon(FPhosphorIcons.arrowsClockwise, size: 18),
                  ),
                ),
              ],
            ),
            if (_showAdvanced) ...[
              const SizedBox(height: 12),
              const FDivider(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildDropdown<String?>(
                    width: 150,
                    label: 'Level',
                    value: widget.selectedLevelId,
                    items: {
                      null: 'All levels',
                      for (final level in widget.levels)
                        if (!level.isArchived) level.id: level.nameEn,
                    },
                    onChanged: widget.onSelectLevel,
                  ),
                  _buildDropdown<int?>(
                    width: 175,
                    label: 'Topic',
                    value: widget.filter.topicId,
                    items: {
                      null: 'All topics',
                      for (final topic in widget.topics)
                        if (int.tryParse(topic.id) != null)
                          int.parse(topic.id): topic.nameBn.isNotEmpty
                              ? topic.nameBn
                              : topic.nameEn,
                    },
                    onChanged: widget.topics.isEmpty
                        ? null
                        : widget.onSelectTopic,
                  ),
                  _buildDropdown<McqSourceType?>(
                    width: 150,
                    label: 'Source',
                    value: widget.filter.sourceType,
                    items: {
                      null: 'All sources',
                      for (final source in McqSourceType.values)
                        source: source.label,
                    },
                    onChanged: widget.onSelectSourceType,
                  ),
                  _buildDropdown<McqDifficulty?>(
                    width: 150,
                    label: 'Difficulty',
                    value: widget.filter.difficulty,
                    items: {
                      null: 'All difficulties',
                      for (final difficulty in McqDifficulty.values)
                        difficulty: difficulty.label,
                    },
                    onChanged: widget.onSelectDifficulty,
                  ),
                  _buildDropdown<McqRightsStatus?>(
                    width: 165,
                    label: 'Rights',
                    value: widget.filter.rightsStatus,
                    items: {
                      null: 'All rights',
                      for (final rights in McqRightsStatus.values)
                        rights: rights.label,
                    },
                    onChanged: widget.onSelectRightsStatus,
                  ),
                  _buildDropdown<String?>(
                    width: 165,
                    label: 'Board',
                    value: widget.filter.boardId,
                    items: {
                      null: 'All boards',
                      for (final board in widget.boards)
                        board.id: board.nameBn.isNotEmpty
                            ? board.nameBn
                            : board.nameEn,
                    },
                    onChanged: widget.onSelectBoard,
                  ),
                  SizedBox(
                    width: 115,
                    child: FTextField(
                      control: FTextFieldControl.managed(
                        controller: _yearController,
                        onChange: (value) {
                          final trimmed = value.text.trim();
                          if (trimmed.isEmpty) {
                            widget.onSetExamYear(null);
                          } else if (trimmed.length == 4) {
                            final parsed = int.tryParse(trimmed);
                            if (parsed != null &&
                                parsed >= 1990 &&
                                parsed <= 2100) {
                              widget.onSetExamYear(parsed);
                            }
                          }
                        },
                      ),
                      label: const Text('Year'),
                      hint: '2024',
                      keyboardType: TextInputType.number,
                      onSubmit: (raw) {
                        final parsed = int.tryParse(raw.trim());
                        widget.onSetExamYear(parsed);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required double width,
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return SizedBox(
      width: width,
      child: FSelect<T>.rich(
        label: Text(label),
        enabled: onChanged != null,
        control: FSelectControl<T>.lifted(
          value: value,
          onChange: onChanged ?? (_) {},
        ),
        format: (value) => items[value] ?? label,
        children: [
          for (final item in items.entries)
            FSelectItem<T>(
              value: item.key,
              title: Text(item.value, overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
    );
  }
}
