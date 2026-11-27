// Pure-Dart role permission helpers mirroring 0003_mcq_bank_and_import.sql RLS.
// Keeps UI buttons aligned with server-enforced review gates.
import 'imports/question_bank_permissions_imports.dart';

abstract final class QuestionBankPermissions {
  static bool canPublish(AdminRole role) =>
      role == AdminRole.superAdmin || role == AdminRole.reviewer;

  static bool canDelete(AdminRole role) => role == AdminRole.superAdmin;

  static bool canPerformAction({
    required AdminRole role,
    required McqQuestion question,
    required QuestionBankModerationAction action,
  }) {
    switch (action) {
      case QuestionBankModerationAction.approveAndPublish:
        return canPublish(role) &&
            (question.status != McqStatus.published || !question.isVerified);
      case QuestionBankModerationAction.sendToDraft:
        if (role == AdminRole.editor) {
          return !question.isFrozenForEditor &&
              question.status == McqStatus.inReview;
        }
        return canPublish(role) && question.status != McqStatus.draft;
      case QuestionBankModerationAction.submitForReview:
        if (question.isFrozenForEditor && role == AdminRole.editor) {
          return false;
        }
        return question.status == McqStatus.draft;
      case QuestionBankModerationAction.archive:
        if (question.isArchived) return false;
        if (role == AdminRole.editor) return !question.isFrozenForEditor;
        return canPublish(role);
      case QuestionBankModerationAction.restore:
        if (!question.isArchived) return false;
        if (role == AdminRole.editor) return !question.isFrozenForEditor;
        return canPublish(role);
      case QuestionBankModerationAction.deletePermanently:
        return canDelete(role);
    }
  }

  static bool canSelectForBulk(AdminRole role, McqQuestion question) {
    if (canPublish(role)) return true;
    return role == AdminRole.editor && !question.isFrozenForEditor;
  }

  /// Builds the PostgREST update map for a given moderation action.
  static Map<String, dynamic> buildUpdatePayload(
    QuestionBankModerationAction action, {
    DateTime? now,
  }) {
    final timestamp = (now ?? DateTime.now().toUtc()).toIso8601String();
    switch (action) {
      case QuestionBankModerationAction.submitForReview:
        return <String, dynamic>{
          'status': McqStatus.inReview.dbValue,
          'archived_at': null,
        };
      case QuestionBankModerationAction.approveAndPublish:
        return <String, dynamic>{
          'status': McqStatus.published.dbValue,
          'is_verified': true,
          'archived_at': null,
        };
      case QuestionBankModerationAction.sendToDraft:
        return <String, dynamic>{
          'status': McqStatus.draft.dbValue,
          'is_verified': false,
          'archived_at': null,
        };
      case QuestionBankModerationAction.archive:
        return <String, dynamic>{
          'status': McqStatus.archived.dbValue,
          'archived_at': timestamp,
        };
      case QuestionBankModerationAction.restore:
        return <String, dynamic>{
          'status': McqStatus.draft.dbValue,
          'archived_at': null,
        };
      case QuestionBankModerationAction.deletePermanently:
        return const <String, dynamic>{};
    }
  }

  /// Sanitizes user search text before interpolating into a PostgREST `.or()` filter.
  static String sanitizeSearchForPostgrest(String raw) {
    return raw
        .replaceAll(',', ' ')
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .replaceAll('%', '')
        .replaceAll('*', '')
        .trim();
  }
}
