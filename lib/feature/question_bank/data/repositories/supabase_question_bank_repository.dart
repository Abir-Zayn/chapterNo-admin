// PostgREST implementation of QuestionBankRepository against public.mcq_questions.
// Supports server-side pagination, multi-axis filters, and role-safe moderation.
import 'imports/supabase_question_bank_repository_imports.dart';

final class SupabaseQuestionBankRepository implements QuestionBankRepository {
  SupabaseQuestionBankRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<QuestionBankPage> fetchQuestions(QuestionBankFilter filter) async {
    try {
      PostgrestFilterBuilder<PostgrestList> query = _client
          .from(kMcqQuestionsTable)
          .select(kMcqQuestionSelectColumns);

      if (filter.subjectId != null) {
        query = query.eq('subject_id', filter.subjectId!);
      }
      if (filter.chapterId != null) {
        query = query.eq('chapter_id', filter.chapterId!);
      }
      if (filter.topicId != null) {
        query = query.eq('topic_id', filter.topicId!);
      }
      if (filter.boardId != null && filter.boardId!.isNotEmpty) {
        query = query.eq('board_id', filter.boardId!);
      }
      if (filter.examYear != null) {
        query = query.eq('exam_year', filter.examYear!);
      }
      if (filter.status != null) {
        query = query.eq('status', filter.status!.dbValue);
      }
      if (filter.sourceType != null) {
        query = query.eq('source_type', filter.sourceType!.dbValue);
      }
      if (filter.difficulty != null) {
        query = query.eq('difficulty', filter.difficulty!.dbValue);
      }
      if (filter.rightsStatus != null) {
        query = query.eq('rights_status', filter.rightsStatus!.dbValue);
      }

      final sanitizedSearch = QuestionBankPermissions.sanitizeSearchForPostgrest(
        filter.searchQuery,
      );
      if (sanitizedSearch.isNotEmpty) {
        query = query.or(
          'title.ilike.%$sanitizedSearch%,external_code.ilike.%$sanitizedSearch%',
        );
      }

      final response = await query
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .range(filter.rangeFrom, filter.rangeTo)
          .count(CountOption.exact);

      final items = response.data
          .map((row) => McqQuestionModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      return QuestionBankPage(
        items: items,
        totalCount: response.count,
        page: filter.page,
        pageSize: filter.pageSize,
      );
    } on AppFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error, 'Failed to load questions');
    } catch (error) {
      throw NetworkFailure('Failed to load questions: $error');
    }
  }

  @override
  Future<void> updateQuestionsStatus({
    required List<String> questionIds,
    required QuestionBankModerationAction action,
  }) async {
    if (questionIds.isEmpty) return;
    final payload = QuestionBankPermissions.buildUpdatePayload(action);
    if (payload.isEmpty) return;

    try {
      await _client
          .from(kMcqQuestionsTable)
          .update(payload)
          .inFilter('id', questionIds);
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error, 'Failed to update question status');
    } catch (error) {
      throw NetworkFailure('Failed to update question status: $error');
    }
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    try {
      await _client.from(kMcqQuestionsTable).delete().eq('id', questionId);
    } on PostgrestException catch (error) {
      throw _mapPostgrestError(error, 'Failed to delete question');
    } catch (error) {
      throw NetworkFailure('Failed to delete question: $error');
    }
  }

  AppFailure _mapPostgrestError(PostgrestException error, String prefix) {
    if (error.code == '42501') {
      return const ForbiddenFailure(
        'Permission denied (42501): your role cannot perform this action on '
        'published or verified questions.',
      );
    }
    if (error.code == '22023' || error.code == '23514') {
      return ValidationFailure('$prefix: ${error.message}');
    }
    return NetworkFailure('$prefix: ${error.message}');
  }
}
