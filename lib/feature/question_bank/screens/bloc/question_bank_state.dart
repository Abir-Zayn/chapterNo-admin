// Immutable state for the Question Bank Browser: curriculum filters,
// paginated questions, bulk selection, and moderation feedback.
import 'imports/question_bank_state_imports.dart';

class QuestionBankState extends Equatable {
  const QuestionBankState({
    this.status = QuestionBankLoadStatus.initial,
    this.levels = const [],
    this.boards = const [],
    this.subjects = const [],
    this.chapters = const [],
    this.selectedLevelId,
    this.filter = const QuestionBankFilter(),
    this.items = const [],
    this.totalCount = 0,
    this.selectedIds = const {},
    this.isFetchingPage = false,
    this.isLoadingChapters = false,
    this.isModerating = false,
    this.feedbackMessage,
    this.errorMessage,
    this.errorStatusCode,
  });

  final QuestionBankLoadStatus status;
  final List<EducationLevel> levels;
  final List<Board> boards;
  final List<Subject> subjects;
  final List<Chapter> chapters;
  final String? selectedLevelId;
  final QuestionBankFilter filter;
  final List<McqQuestion> items;
  final int totalCount;
  final Set<String> selectedIds;
  final bool isFetchingPage;
  final bool isLoadingChapters;
  final bool isModerating;
  final String? feedbackMessage;
  final String? errorMessage;
  final int? errorStatusCode;

  int get totalPages =>
      totalCount == 0 ? 1 : (totalCount / filter.pageSize).ceil();

  bool get hasPreviousPage => filter.page > 1;

  bool get hasNextPage => filter.page < totalPages;

  int get showingFrom =>
      totalCount == 0 ? 0 : ((filter.page - 1) * filter.pageSize) + 1;

  int get showingTo {
    if (totalCount == 0) return 0;
    final end = (filter.page - 1) * filter.pageSize + items.length;
    return end > totalCount ? totalCount : end;
  }

  List<Board> get boardsForLevel => boards
      .where(
        (board) =>
            !board.isArchived &&
            (selectedLevelId == null ||
                board.educationLevelId == selectedLevelId),
      )
      .toList();

  List<Chapter> get activeChapters =>
      chapters.where((chapter) => !chapter.isArchived).toList();

  List<Topic> get topicsForSelectedChapter {
    final chapterId = filter.chapterId;
    if (chapterId == null) return const [];
    for (final chapter in activeChapters) {
      if (int.tryParse(chapter.id) == chapterId) {
        return chapter.topics.where((topic) => !topic.isArchived).toList();
      }
    }
    return const [];
  }

  Map<int, String> get subjectLabelsById {
    final map = <int, String>{};
    for (final subject in subjects) {
      final id = int.tryParse(subject.id);
      if (id != null) {
        map[id] = subject.nameBn.isNotEmpty ? subject.nameBn : subject.nameEn;
      }
    }
    return map;
  }

  Map<int, String> get chapterLabelsById {
    final map = <int, String>{};
    for (final chapter in chapters) {
      final id = int.tryParse(chapter.id);
      if (id != null) {
        map[id] = '${chapter.code} · ${chapter.nameBn}';
      }
    }
    return map;
  }

  Map<String, String> get boardLabelsById {
    final map = <String, String>{};
    for (final board in boards) {
      map[board.id] = board.nameBn.isNotEmpty ? board.nameBn : board.nameEn;
    }
    return map;
  }

  QuestionBankState copyWith({
    QuestionBankLoadStatus? status,
    List<EducationLevel>? levels,
    List<Board>? boards,
    List<Subject>? subjects,
    List<Chapter>? chapters,
    String? selectedLevelId,
    bool clearSelectedLevel = false,
    QuestionBankFilter? filter,
    List<McqQuestion>? items,
    int? totalCount,
    Set<String>? selectedIds,
    bool? isFetchingPage,
    bool? isLoadingChapters,
    bool? isModerating,
    String? feedbackMessage,
    bool clearFeedback = false,
    String? errorMessage,
    int? errorStatusCode,
    bool clearError = false,
  }) {
    return QuestionBankState(
      status: status ?? this.status,
      levels: levels ?? this.levels,
      boards: boards ?? this.boards,
      subjects: subjects ?? this.subjects,
      chapters: chapters ?? this.chapters,
      selectedLevelId: clearSelectedLevel
          ? null
          : (selectedLevelId ?? this.selectedLevelId),
      filter: filter ?? this.filter,
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      selectedIds: selectedIds ?? this.selectedIds,
      isFetchingPage: isFetchingPage ?? this.isFetchingPage,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      isModerating: isModerating ?? this.isModerating,
      feedbackMessage: clearFeedback
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorStatusCode: clearError
          ? null
          : (errorStatusCode ?? this.errorStatusCode),
    );
  }

  @override
  List<Object?> get props => [
    status,
    levels,
    boards,
    subjects,
    chapters,
    selectedLevelId,
    filter,
    items,
    totalCount,
    selectedIds,
    isFetchingPage,
    isLoadingChapters,
    isModerating,
    feedbackMessage,
    errorMessage,
    errorStatusCode,
  ];
}
