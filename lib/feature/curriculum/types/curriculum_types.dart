// Pure-Dart UI and domain enums for the Curriculum Catalogue feature.
// Represents active workspace tabs and editable curriculum node tiers.

enum CurriculumTab { syllabus, boardsAndLevels }

enum CurriculumNodeKind {
  educationLevel('Education Level'),
  board('Board'),
  subject('Subject'),
  chapter('Chapter'),
  topic('Topic');

  const CurriculumNodeKind(this.label);

  final String label;
}
