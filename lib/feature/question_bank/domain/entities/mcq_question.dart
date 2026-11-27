// Pure-Dart domain entities for Question Bank browsing, filtering, and pagination.
import 'imports/mcq_question_imports.dart';

class McqOption extends Equatable {
  const McqOption({required this.key, required this.text});

  final String key;
  final String text;

  @override
  List<Object?> get props => [key, text];
}

class McqQuestion extends Equatable {
  const McqQuestion({
    required this.id,
    required this.subjectId,
    required this.chapterId,
    required this.questionType,
    required this.title,
    required this.options,
    required this.correctOption,
    required this.difficulty,
    required this.sourceType,
    required this.rightsStatus,
    required this.status,
    required this.isVerified,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.externalCode,
    this.topicId,
    this.stimulusId,
    this.statements = const [],
    this.explanation,
    this.boardId,
    this.examYear,
    this.archivedAt,
  });

  final String id;
  final String? externalCode;
  final int subjectId;
  final int chapterId;
  final int? topicId;
  final String? stimulusId;
  final McqQuestionType questionType;
  final String title;
  final List<String> statements;
  final List<McqOption> options;
  final String correctOption;
  final String? explanation;
  final McqDifficulty difficulty;
  final McqSourceType sourceType;
  final String? boardId;
  final int? examYear;
  final McqRightsStatus rightsStatus;
  final McqStatus status;
  final bool isVerified;
  final int version;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isArchived => status == McqStatus.archived || archivedAt != null;

  bool get isFrozenForEditor => status == McqStatus.published || isVerified;

  @override
  List<Object?> get props => [
    id,
    externalCode,
    subjectId,
    chapterId,
    topicId,
    stimulusId,
    questionType,
    title,
    statements,
    options,
    correctOption,
    explanation,
    difficulty,
    sourceType,
    boardId,
    examYear,
    rightsStatus,
    status,
    isVerified,
    version,
    archivedAt,
    createdAt,
    updatedAt,
  ];
}

class QuestionBankFilter extends Equatable {
  const QuestionBankFilter({
    this.searchQuery = '',
    this.subjectId,
    this.chapterId,
    this.topicId,
    this.boardId,
    this.examYear,
    this.status,
    this.sourceType,
    this.difficulty,
    this.rightsStatus,
    this.page = 1,
    this.pageSize = 25,
  });

  final String searchQuery;
  final int? subjectId;
  final int? chapterId;
  final int? topicId;
  final String? boardId;
  final int? examYear;
  final McqStatus? status;
  final McqSourceType? sourceType;
  final McqDifficulty? difficulty;
  final McqRightsStatus? rightsStatus;
  final int page;
  final int pageSize;

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      subjectId != null ||
      chapterId != null ||
      topicId != null ||
      boardId != null ||
      examYear != null ||
      status != null ||
      sourceType != null ||
      difficulty != null ||
      rightsStatus != null;

  int get rangeFrom => (page - 1) * pageSize;

  int get rangeTo => rangeFrom + pageSize - 1;

  QuestionBankFilter copyWith({
    String? searchQuery,
    int? subjectId,
    bool clearSubject = false,
    int? chapterId,
    bool clearChapter = false,
    int? topicId,
    bool clearTopic = false,
    String? boardId,
    bool clearBoard = false,
    int? examYear,
    bool clearExamYear = false,
    McqStatus? status,
    bool clearStatus = false,
    McqSourceType? sourceType,
    bool clearSourceType = false,
    McqDifficulty? difficulty,
    bool clearDifficulty = false,
    McqRightsStatus? rightsStatus,
    bool clearRightsStatus = false,
    int? page,
    int? pageSize,
  }) {
    return QuestionBankFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      subjectId: clearSubject ? null : (subjectId ?? this.subjectId),
      chapterId: clearChapter ? null : (chapterId ?? this.chapterId),
      topicId: clearTopic ? null : (topicId ?? this.topicId),
      boardId: clearBoard ? null : (boardId ?? this.boardId),
      examYear: clearExamYear ? null : (examYear ?? this.examYear),
      status: clearStatus ? null : (status ?? this.status),
      sourceType: clearSourceType ? null : (sourceType ?? this.sourceType),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      rightsStatus: clearRightsStatus
          ? null
          : (rightsStatus ?? this.rightsStatus),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
    searchQuery,
    subjectId,
    chapterId,
    topicId,
    boardId,
    examYear,
    status,
    sourceType,
    difficulty,
    rightsStatus,
    page,
    pageSize,
  ];
}

class QuestionBankPage extends Equatable {
  const QuestionBankPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<McqQuestion> items;
  final int totalCount;
  final int page;
  final int pageSize;

  int get totalPages => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();

  bool get hasPreviousPage => page > 1;

  bool get hasNextPage => page < totalPages;

  int get showingFrom => totalCount == 0 ? 0 : ((page - 1) * pageSize) + 1;

  int get showingTo {
    if (totalCount == 0) return 0;
    final end = (page - 1) * pageSize + items.length;
    return end > totalCount ? totalCount : end;
  }

  @override
  List<Object?> get props => [items, totalCount, page, pageSize];
}
