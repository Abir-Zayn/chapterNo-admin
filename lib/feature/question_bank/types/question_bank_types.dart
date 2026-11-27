// Enums for Question Bank filtering, display badges, and moderation actions.

enum McqStatus {
  draft('draft', 'Draft'),
  inReview('in_review', 'In Review'),
  published('published', 'Published'),
  archived('archived', 'Archived');

  const McqStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static McqStatus fromDbValue(String? raw) {
    for (final value in values) {
      if (value.dbValue == raw) return value;
    }
    return McqStatus.draft;
  }
}

enum McqSourceType {
  board('board', 'Board'),
  curated('curated', 'Curated'),
  aiGenerated('ai_generated', 'AI Generated');

  const McqSourceType(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static McqSourceType fromDbValue(String? raw) {
    for (final value in values) {
      if (value.dbValue == raw) return value;
    }
    return McqSourceType.curated;
  }
}

enum McqDifficulty {
  l1('l1', 'L1 · Low'),
  l2('l2', 'L2 · Medium'),
  l3('l3', 'L3 · Hard');

  const McqDifficulty(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static McqDifficulty fromDbValue(String? raw) {
    for (final value in values) {
      if (value.dbValue == raw) return value;
    }
    return McqDifficulty.l2;
  }
}

enum McqRightsStatus {
  internal('internal', 'Internal'),
  publicBoard('public_board', 'Public Board'),
  licensed('licensed', 'Licensed'),
  pendingReview('pending_review', 'Pending Review');

  const McqRightsStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static McqRightsStatus fromDbValue(String? raw) {
    for (final value in values) {
      if (value.dbValue == raw) return value;
    }
    return McqRightsStatus.internal;
  }
}

enum McqQuestionType {
  simple('simple', 'Simple'),
  multipleCompletion('multiple_completion', 'Multiple Completion'),
  stimulus('stimulus', 'Stimulus');

  const McqQuestionType(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static McqQuestionType fromDbValue(String? raw) {
    for (final value in values) {
      if (value.dbValue == raw) return value;
    }
    return McqQuestionType.simple;
  }
}

enum QuestionBankLoadStatus { initial, loading, ready, error }

enum QuestionBankModerationAction {
  submitForReview,
  approveAndPublish,
  sendToDraft,
  archive,
  restore,
  deletePermanently,
}
