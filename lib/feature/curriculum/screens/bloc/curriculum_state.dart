// Immutable state for Curriculum Catalogue browsing, filtering, and editing.
// Holds cascading selections across Level -> Subject -> Chapter -> Topic.
import 'imports/curriculum_state_imports.dart';

enum CurriculumStatus { initial, loading, ready, error }

class CurriculumState extends Equatable {
  const CurriculumState({
    this.status = CurriculumStatus.initial,
    this.levels = const [],
    this.boards = const [],
    this.subjects = const [],
    this.chapters = const [],
    this.selectedLevelId,
    this.selectedSubjectId,
    this.selectedChapterId,
    this.selectedGroup,
    this.activeTab = CurriculumTab.syllabus,
    this.showArchived = false,
    this.searchQuery = '',
    this.isLoadingSubjects = false,
    this.isLoadingChapters = false,
    this.isMutating = false,
    this.errorMessage,
  });

  final CurriculumStatus status;
  final List<EducationLevel> levels;
  final List<Board> boards;
  final List<Subject> subjects;
  final List<Chapter> chapters;
  final String? selectedLevelId;
  final String? selectedSubjectId;
  final String? selectedChapterId;
  final AcademicGroup? selectedGroup;
  final CurriculumTab activeTab;
  final bool showArchived;
  final String searchQuery;
  final bool isLoadingSubjects;
  final bool isLoadingChapters;
  final bool isMutating;
  final String? errorMessage;

  List<EducationLevel> get visibleLevels => showArchived
      ? levels
      : levels.where((level) => !level.isArchived).toList();

  List<Board> get visibleBoards {
    final query = searchQuery.trim().toLowerCase();
    return boards.where((board) {
      if (selectedLevelId != null &&
          board.educationLevelId != selectedLevelId) {
        return false;
      }
      if (!showArchived && board.isArchived) return false;
      if (query.isEmpty) return true;
      return _matchesQuery(
        query,
        nameBn: board.nameBn,
        nameEn: board.nameEn,
        code: board.code,
      );
    }).toList();
  }

  List<Subject> get visibleSubjects {
    final query = searchQuery.trim().toLowerCase();
    return subjects.where((subject) {
      if (!showArchived && subject.isArchived) return false;
      if (selectedGroup != null && subject.academicGroup != selectedGroup) {
        return false;
      }
      if (query.isEmpty) return true;
      return _matchesQuery(
        query,
        nameBn: subject.nameBn,
        nameEn: subject.nameEn,
        code: subject.code,
        extra: subject.nctbCode,
      );
    }).toList();
  }

  List<Chapter> get visibleChapters {
    final query = searchQuery.trim().toLowerCase();
    return chapters.where((chapter) {
      if (!showArchived && chapter.isArchived) return false;
      if (query.isEmpty) return true;
      final chapterMatches = _matchesQuery(
        query,
        nameBn: chapter.nameBn,
        nameEn: chapter.nameEn,
        code: chapter.code,
      );
      if (chapterMatches) return true;
      return chapter.topics.any(
        (topic) =>
            (showArchived || !topic.isArchived) &&
            _matchesQuery(
              query,
              nameBn: topic.nameBn,
              nameEn: topic.nameEn,
              code: topic.code,
            ),
      );
    }).toList();
  }

  Subject? get selectedSubject {
    if (selectedSubjectId == null) return null;
    for (final subject in subjects) {
      if (subject.id == selectedSubjectId) return subject;
    }
    return null;
  }

  Chapter? get selectedChapter {
    if (selectedChapterId == null) return null;
    for (final chapter in chapters) {
      if (chapter.id == selectedChapterId) return chapter;
    }
    return null;
  }

  List<Topic> get visibleTopics {
    final chapter = selectedChapter;
    if (chapter == null) return const [];
    final query = searchQuery.trim().toLowerCase();
    return chapter.topics.where((topic) {
      if (!showArchived && topic.isArchived) return false;
      if (query.isEmpty) return true;
      return _matchesQuery(
        query,
        nameBn: topic.nameBn,
        nameEn: topic.nameEn,
        code: topic.code,
      );
    }).toList();
  }

  bool _matchesQuery(
    String query, {
    required String nameBn,
    required String nameEn,
    required String code,
    String? extra,
  }) {
    return nameBn.toLowerCase().contains(query) ||
        nameEn.toLowerCase().contains(query) ||
        code.toLowerCase().contains(query) ||
        (extra != null && extra.toLowerCase().contains(query));
  }

  CurriculumState copyWith({
    CurriculumStatus? status,
    List<EducationLevel>? levels,
    List<Board>? boards,
    List<Subject>? subjects,
    List<Chapter>? chapters,
    String? selectedLevelId,
    bool clearSelectedLevel = false,
    String? selectedSubjectId,
    bool clearSelectedSubject = false,
    String? selectedChapterId,
    bool clearSelectedChapter = false,
    AcademicGroup? selectedGroup,
    bool clearSelectedGroup = false,
    CurriculumTab? activeTab,
    bool? showArchived,
    String? searchQuery,
    bool? isLoadingSubjects,
    bool? isLoadingChapters,
    bool? isMutating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CurriculumState(
      status: status ?? this.status,
      levels: levels ?? this.levels,
      boards: boards ?? this.boards,
      subjects: subjects ?? this.subjects,
      chapters: chapters ?? this.chapters,
      selectedLevelId: clearSelectedLevel
          ? null
          : (selectedLevelId ?? this.selectedLevelId),
      selectedSubjectId: clearSelectedSubject
          ? null
          : (selectedSubjectId ?? this.selectedSubjectId),
      selectedChapterId: clearSelectedChapter
          ? null
          : (selectedChapterId ?? this.selectedChapterId),
      selectedGroup: clearSelectedGroup
          ? null
          : (selectedGroup ?? this.selectedGroup),
      activeTab: activeTab ?? this.activeTab,
      showArchived: showArchived ?? this.showArchived,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingSubjects: isLoadingSubjects ?? this.isLoadingSubjects,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
    selectedSubjectId,
    selectedChapterId,
    selectedGroup,
    activeTab,
    showArchived,
    searchQuery,
    isLoadingSubjects,
    isLoadingChapters,
    isMutating,
    errorMessage,
  ];
}
