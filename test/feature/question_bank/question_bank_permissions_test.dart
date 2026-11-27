import 'package:chapterno_admin/feature/auth/types/admin_role.dart';
import 'package:chapterno_admin/feature/question_bank/domain/entities/mcq_question.dart';
import 'package:chapterno_admin/feature/question_bank/types/question_bank_types.dart';
import 'package:chapterno_admin/feature/question_bank/utils/question_bank_permissions.dart';
import 'package:flutter_test/flutter_test.dart';

McqQuestion _makeQuestion({
  McqStatus status = McqStatus.draft,
  bool isVerified = false,
}) {
  return McqQuestion(
    id: 'q1',
    subjectId: 1,
    chapterId: 2,
    questionType: McqQuestionType.simple,
    title: 'Test?',
    options: const [
      McqOption(key: '1', text: 'A'),
      McqOption(key: '2', text: 'B'),
    ],
    correctOption: '1',
    difficulty: McqDifficulty.l2,
    sourceType: McqSourceType.curated,
    rightsStatus: McqRightsStatus.internal,
    status: status,
    isVerified: isVerified,
    version: 1,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

void main() {
  group('QuestionBankPermissions', () {
    test('editor can submit draft for review but never publish or edit published rows', () {
      final draft = _makeQuestion(status: McqStatus.draft);
      final published = _makeQuestion(
        status: McqStatus.published,
        isVerified: true,
      );

      expect(
        QuestionBankPermissions.canPerformAction(
          role: AdminRole.editor,
          question: draft,
          action: QuestionBankModerationAction.submitForReview,
        ),
        isTrue,
      );
      expect(
        QuestionBankPermissions.canPerformAction(
          role: AdminRole.editor,
          question: draft,
          action: QuestionBankModerationAction.approveAndPublish,
        ),
        isFalse,
      );
      expect(
        QuestionBankPermissions.canPerformAction(
          role: AdminRole.editor,
          question: published,
          action: QuestionBankModerationAction.archive,
        ),
        isFalse,
      );
      expect(
        QuestionBankPermissions.canSelectForBulk(AdminRole.editor, published),
        isFalse,
      );
      expect(
        QuestionBankPermissions.canPerformAction(
          role: AdminRole.editor,
          question: draft,
          action: QuestionBankModerationAction.deletePermanently,
        ),
        isFalse,
      );
    });

    test('reviewer can publish and archive but cannot delete permanently', () {
      final draft = _makeQuestion(status: McqStatus.draft);

      expect(
        QuestionBankPermissions.canPerformAction(
          role: AdminRole.reviewer,
          question: draft,
          action: QuestionBankModerationAction.approveAndPublish,
        ),
        isTrue,
      );
      expect(
        QuestionBankPermissions.canPerformAction(
          role: AdminRole.reviewer,
          question: draft,
          action: QuestionBankModerationAction.deletePermanently,
        ),
        isFalse,
      );
    });

    test('super_admin can publish and delete permanently', () {
      final published = _makeQuestion(
        status: McqStatus.published,
        isVerified: true,
      );

      expect(
        QuestionBankPermissions.canPerformAction(
          role: AdminRole.superAdmin,
          question: published,
          action: QuestionBankModerationAction.sendToDraft,
        ),
        isTrue,
      );
      expect(
        QuestionBankPermissions.canPerformAction(
          role: AdminRole.superAdmin,
          question: published,
          action: QuestionBankModerationAction.deletePermanently,
        ),
        isTrue,
      );
    });

    test('sanitizes PostgREST .or() special characters safely', () {
      expect(
        QuestionBankPermissions.sanitizeSearchForPostgrest('  F=ma, (test)%* '),
        'F=ma   test',
      );
    });
  });
}
