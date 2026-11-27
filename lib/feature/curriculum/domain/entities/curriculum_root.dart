// Pure-Dart aggregate holding top-level Education Levels and Boards.
// Returned by CurriculumRepository.fetchRoot() for initial workspace load.
import 'board.dart';
import 'curriculum_entity_imports.dart';
import 'education_level.dart';

class CurriculumRoot extends Equatable {
  const CurriculumRoot({required this.levels, required this.boards});

  final List<EducationLevel> levels;
  final List<Board> boards;

  @override
  List<Object?> get props => [levels, boards];
}
