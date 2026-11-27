// Immutable state for the bulk importer: curriculum context, parsed rows,
// validation results, and chunked submit progress.
import 'imports/bulk_import_state_imports.dart';

enum BulkImportStatus { initial, loading, ready, error }

enum BulkImportSubmitPhase { idle, submitting, success, failure }

class BulkImportState extends Equatable {
  const BulkImportState({
    this.status = BulkImportStatus.initial,
    this.levels = const [],
    this.boards = const [],
    this.subjects = const [],
    this.chapters = const [],
    this.selectedLevelId,
    this.selectedSubjectId,
    this.selectedChapterId,
    this.selectedBoardId,
    this.inputMode = ImportInputMode.paste,
    this.sourceName,
    this.sourceText = '',
    this.rows = const [],
    this.rowFilter = RowViewFilter.all,
    this.isLoadingChapters = false,
    this.submitPhase = BulkImportSubmitPhase.idle,
    this.submitChunksDone = 0,
    this.submitChunksTotal = 0,
    this.summary,
    this.encodingWarning,
    this.errorMessage,
    this.errorStatusCode,
  });

  final BulkImportStatus status;
  final List<EducationLevel> levels;
  final List<Board> boards;
  final List<Subject> subjects;
  final List<Chapter> chapters;
  final String? selectedLevelId;
  final String? selectedSubjectId;
  final String? selectedChapterId;
  final String? selectedBoardId;
  final ImportInputMode inputMode;
  final String? sourceName;
  final String sourceText;
  final List<McqRowDraft> rows;
  final RowViewFilter rowFilter;
  final bool isLoadingChapters;
  final BulkImportSubmitPhase submitPhase;
  final int submitChunksDone;
  final int submitChunksTotal;
  final McqBatchUpsertResult? summary;
  final String? encodingWarning;
  final String? errorMessage;
  final int? errorStatusCode;

  Subject? get selectedSubject {
    final id = selectedSubjectId;
    if (id == null) return null;
    for (final subject in subjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }

  Chapter? get selectedChapter {
    final id = selectedChapterId;
    if (id == null) return null;
    for (final chapter in chapters) {
      if (chapter.id == id) return chapter;
    }
    return null;
  }

  Board? get selectedBoard {
    final id = selectedBoardId;
    if (id == null) return null;
    for (final board in boards) {
      if (board.id == id) return board;
    }
    return null;
  }

  /// Subject bigint id parsed for the upsert payload; null when unresolved.
  int? get selectedSubjectIntId => int.tryParse(selectedSubject?.id ?? '');

  List<Board> get boardsForLevel => boards
      .where(
        (board) =>
            !board.isArchived &&
            (selectedLevelId == null ||
                board.educationLevelId == selectedLevelId),
      )
      .toList();

  List<Chapter> get activeChapters => chapters
      .where((chapter) => !chapter.isArchived)
      .toList();

  /// chapter code -> bigint id map used by row validation.
  Map<String, int> get chapterIdsByCode {
    final map = <String, int>{};
    for (final chapter in activeChapters) {
      final id = int.tryParse(chapter.id);
      if (chapter.code.isNotEmpty && id != null) {
        map[chapter.code] = id;
      }
    }
    return map;
  }

  /// Default chapter bigint id from the context picker (optional).
  int? get defaultChapterIntId {
    final chapter = selectedChapter;
    if (chapter == null) return null;
    return int.tryParse(chapter.id);
  }

  int get totalRows => rows.length;
  int get validRowCount => rows.where((row) => row.isValid).length;
  int get errorRowCount => totalRows - validRowCount;
  bool get hasSource => sourceName != null;

  List<McqRowDraft> get visibleRows => switch (rowFilter) {
    RowViewFilter.all => rows,
    RowViewFilter.validOnly => rows.where((row) => row.isValid).toList(),
    RowViewFilter.errorOnly => rows.where((row) => !row.isValid).toList(),
  };

  bool get isSubmitting => submitPhase == BulkImportSubmitPhase.submitting;

  BulkImportState copyWith({
    BulkImportStatus? status,
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
    String? selectedBoardId,
    bool clearSelectedBoard = false,
    ImportInputMode? inputMode,
    String? sourceName,
    bool clearSourceName = false,
    String? sourceText,
    List<McqRowDraft>? rows,
    RowViewFilter? rowFilter,
    bool? isLoadingChapters,
    BulkImportSubmitPhase? submitPhase,
    int? submitChunksDone,
    int? submitChunksTotal,
    McqBatchUpsertResult? summary,
    bool clearSummary = false,
    String? encodingWarning,
    bool clearEncodingWarning = false,
    String? errorMessage,
    int? errorStatusCode,
    bool clearError = false,
  }) {
    return BulkImportState(
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
      selectedBoardId: clearSelectedBoard
          ? null
          : (selectedBoardId ?? this.selectedBoardId),
      inputMode: inputMode ?? this.inputMode,
      sourceName: clearSourceName
          ? null
          : (sourceName ?? this.sourceName),
      sourceText: sourceText ?? this.sourceText,
      rows: rows ?? this.rows,
      rowFilter: rowFilter ?? this.rowFilter,
      isLoadingChapters: isLoadingChapters ?? this.isLoadingChapters,
      submitPhase: submitPhase ?? this.submitPhase,
      submitChunksDone: submitChunksDone ?? this.submitChunksDone,
      submitChunksTotal: submitChunksTotal ?? this.submitChunksTotal,
      summary: clearSummary ? null : (summary ?? this.summary),
      encodingWarning: clearEncodingWarning
          ? null
          : (encodingWarning ?? this.encodingWarning),
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
    selectedSubjectId,
    selectedChapterId,
    selectedBoardId,
    inputMode,
    sourceName,
    sourceText,
    rows,
    rowFilter,
    isLoadingChapters,
    submitPhase,
    submitChunksDone,
    submitChunksTotal,
    summary,
    encodingWarning,
    errorMessage,
    errorStatusCode,
  ];
}
