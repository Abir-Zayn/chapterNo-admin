// Cubit orchestrating bulk import: curriculum context, source parsing,
// row validation, re-validation on context change, and chunked submission.
import 'imports/bulk_import_cubit_imports.dart';

class BulkImportCubit extends Cubit<BulkImportState> {
  BulkImportCubit(this._importRepository, this._curriculumRepository)
    : super(const BulkImportState());

  final BulkImportRepository _importRepository;
  final CurriculumRepository _curriculumRepository;

  List<Map<String, dynamic>> _parsedRows = const [];
  final ValidateMcqRowsUseCase _validateRows = const ValidateMcqRowsUseCase();
  late final SubmitMcqBatchUseCase _submitBatch = SubmitMcqBatchUseCase(
    _importRepository,
  );

  Future<void> loadContext() async {
    emit(state.copyWith(status: BulkImportStatus.loading, clearError: true));
    try {
      final root = await _curriculumRepository.fetchRoot();
      final levelId = CurriculumListHelpers.pickPreferredId(
        state.selectedLevelId,
        root.levels
            .where((level) => !level.isArchived)
            .map((level) => level.id)
            .toList(),
      );
      emit(
        state.copyWith(
          status: BulkImportStatus.ready,
          levels: root.levels,
          boards: root.boards,
          selectedLevelId: levelId,
          clearSelectedLevel: levelId == null,
        ),
      );
      if (levelId != null) {
        await _loadSubjectsForLevel(levelId);
      }
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: BulkImportStatus.error,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
    }
  }

  Future<void> selectLevel(String levelId) async {
    if (levelId == state.selectedLevelId) return;
    emit(
      state.copyWith(
        selectedLevelId: levelId,
        clearSelectedSubject: true,
        clearSelectedChapter: true,
        clearSelectedBoard: true,
        subjects: const [],
        chapters: const [],
        clearError: true,
      ),
    );
    await _loadSubjectsForLevel(levelId);
  }

  Future<void> selectSubject(String subjectId) async {
    if (subjectId == state.selectedSubjectId) return;
    emit(
      state.copyWith(
        selectedSubjectId: subjectId,
        clearSelectedChapter: true,
        chapters: const [],
        isLoadingChapters: true,
        clearError: true,
      ),
    );
    try {
      final chapters = await _curriculumRepository.fetchChaptersWithTopics(
        subjectId: subjectId,
      );
      emit(
        state.copyWith(
          isLoadingChapters: false,
          chapters: chapters,
          clearSelectedChapter: true,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          isLoadingChapters: false,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
      return;
    }
    _revalidateRows();
  }

  /// Optional default chapter applied when a row omits chapter_code.
  void selectChapter(String? chapterId) {
    emit(
      state.copyWith(
        selectedChapterId: chapterId,
        clearSelectedChapter: chapterId == null,
        clearError: true,
      ),
    );
    _revalidateRows();
  }

  /// Optional default board applied to every imported row.
  void selectBoard(String? boardId) {
    emit(
      state.copyWith(
        selectedBoardId: boardId,
        clearSelectedBoard: boardId == null,
        clearError: true,
      ),
    );
  }

  void setInputMode(ImportInputMode mode) {
    emit(state.copyWith(inputMode: mode, clearError: true));
  }

  void updateSourceText(String text) {
    emit(state.copyWith(sourceText: text));
  }

  /// Parses the pasted text and validates rows against current context.
  void parseSourceText() {
    final parsed = parseBulkInput(state.sourceText);
    if (!parsed.isOk) {
      emit(
        state.copyWith(
          rows: const [],
          sourceName: null,
          clearSourceName: true,
          errorMessage: parsed.parseError,
          errorStatusCode: 422,
        ),
      );
      _parsedRows = const [];
      return;
    }
    _parsedRows = parsed.rows;
    emit(
      state.copyWith(
        sourceName: 'Pasted CSV / JSON',
        clearEncodingWarning: true,
        clearError: true,
        clearSummary: true,
        submitPhase: BulkImportSubmitPhase.idle,
      ),
    );
    _revalidateRows();
  }

  /// Decodes a picked file strictly as UTF-8; flags legacy ANSI gracefully.
  void ingestFile({required List<int> bytes, required String name}) {
    String decoded;
    String? encodingWarning;
    try {
      decoded = utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      decoded = utf8.decode(bytes, allowMalformed: true);
      encodingWarning =
          'This file is not valid UTF-8 (likely legacy Bijoy ANSI). '
          'Affected rows are flagged below — re-export as UTF-8 CSV.';
    }
    final parsed = parseBulkInput(decoded);
    if (!parsed.isOk) {
      emit(
        state.copyWith(
          sourceName: name,
          sourceText: decoded,
          encodingWarning: encodingWarning,
          rows: const [],
          errorMessage: parsed.parseError,
          errorStatusCode: 422,
        ),
      );
      _parsedRows = const [];
      return;
    }
    _parsedRows = parsed.rows;
    emit(
      state.copyWith(
        sourceName: name,
        sourceText: decoded,
        encodingWarning: encodingWarning,
        clearError: true,
        clearSummary: true,
        submitPhase: BulkImportSubmitPhase.idle,
      ),
    );
    _revalidateRows();
  }

  void clearSource() {
    _parsedRows = const [];
    emit(
      state.copyWith(
        rows: const [],
        clearSourceName: true,
        sourceText: '',
        clearEncodingWarning: true,
        clearSummary: true,
        submitPhase: BulkImportSubmitPhase.idle,
        submitChunksDone: 0,
        submitChunksTotal: 0,
        clearError: true,
      ),
    );
  }

  void setRowFilter(RowViewFilter filter) {
    emit(state.copyWith(rowFilter: filter));
  }

  Future<void> submitValidRows() async {
    if (state.isSubmitting) return;
    final subjectId = state.selectedSubjectIntId;
    if (subjectId == null) {
      emit(
        state.copyWith(
          errorMessage: 'Select a subject before importing.',
          errorStatusCode: 422,
        ),
      );
      return;
    }
    final validRows = state.rows.where((row) => row.isValid).toList();
    if (validRows.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'No valid rows to import. Fix the flagged rows first.',
          errorStatusCode: 422,
        ),
      );
      return;
    }

    final payloads = [
      for (final row in validRows)
        buildMcqRowPayload(
          row,
          subjectId: subjectId,
          defaultBoardId: state.selectedBoard?.id,
        ),
    ];

    emit(
      state.copyWith(
        submitPhase: BulkImportSubmitPhase.submitting,
        submitChunksDone: 0,
        submitChunksTotal: 0,
        clearError: true,
      ),
    );
    try {
      final summary = await _submitBatch(
        payloads,
        onProgress: (chunksDone, chunksTotal) => emit(
          state.copyWith(
            submitChunksDone: chunksDone,
            submitChunksTotal: chunksTotal,
          ),
        ),
      );
      emit(
        state.copyWith(
          submitPhase: BulkImportSubmitPhase.success,
          summary: summary,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          submitPhase: BulkImportSubmitPhase.failure,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _loadSubjectsForLevel(String levelId) async {
    try {
      final subjects = await _curriculumRepository.fetchSubjects(
        levelId: levelId,
        isActive: true,
      );
      final subjectId = CurriculumListHelpers.pickPreferredId(
        state.selectedSubjectId,
        subjects.where((s) => !s.isArchived).map((s) => s.id).toList(),
      );
      // Keep the id unset here so selectSubject() runs its own selection
      // and chapter-loading path instead of early-returning.
      emit(state.copyWith(subjects: subjects));
      if (subjectId != null) {
        await selectSubject(subjectId);
      }
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: BulkImportStatus.error,
          errorMessage: failure.message,
          errorStatusCode: failure.statusCode,
        ),
      );
    }
  }

  void _revalidateRows() {
    if (_parsedRows.isEmpty) return;
    final drafts = _validateRows(_parsedRows, _currentValidationContext());
    emit(state.copyWith(rows: drafts));
  }

  McqRowValidationContext _currentValidationContext() {
    return McqRowValidationContext(
      chapterIdsByCode: state.chapterIdsByCode,
      defaultChapterId: state.defaultChapterIntId,
    );
  }
}
