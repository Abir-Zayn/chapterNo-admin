// Pure-Dart list selection and reorder helpers for CurriculumCubit.
// Keeps ID fallback, immutable list moves, and topic replacement testable.
import 'curriculum_list_helpers_imports.dart';

abstract final class CurriculumListHelpers {
  static String? pickPreferredId(String? preferred, List<String> available) {
    if (available.isEmpty) return null;
    if (preferred != null && available.contains(preferred)) return preferred;
    return available.first;
  }

  static List<T>? applyMove<T>(List<T> items, int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= items.length) return null;
    if (newIndex < 0 || newIndex >= items.length || newIndex == oldIndex) {
      return null;
    }
    final copy = List<T>.from(items);
    final moved = copy.removeAt(oldIndex);
    copy.insert(newIndex, moved);
    return copy;
  }

  static List<Chapter> replaceChapterTopics(
    List<Chapter> chapters, {
    required String chapterId,
    required List<Topic> topics,
  }) {
    return chapters.map((chapter) {
      if (chapter.id != chapterId) return chapter;
      return Chapter(
        id: chapter.id,
        subjectId: chapter.subjectId,
        chapterNumber: chapter.chapterNumber,
        code: chapter.code,
        nameBn: chapter.nameBn,
        nameEn: chapter.nameEn,
        descriptionBn: chapter.descriptionBn,
        displayOrder: chapter.displayOrder,
        isActive: chapter.isActive,
        archivedAt: chapter.archivedAt,
        topics: topics,
      );
    }).toList();
  }
}
