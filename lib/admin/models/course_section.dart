// lib/admin/models/course_section.dart

import 'course_content.dart';

class CourseSection {
  String id;
  String title;
  List<CourseContent> contents;

  // ← UI‐only fields, not persisted to Firestore
  bool isEditing;
  int? editIndex;

  CourseSection({
    required this.id,
    required this.title,
    required this.contents,
    this.isEditing = false,
    this.editIndex,
  });

  /// Create a section with no contents
  factory CourseSection.empty(String id) => CourseSection(
    id: id,
    title: '',
    contents: [],
  );

  /// Convert Firestore map → model
  factory CourseSection.fromMap(String id, Map<String, dynamic> data) {
    final rawContents = data['contents'] as Map<String, dynamic>? ?? {};
    final contents = rawContents.entries
        .map((e) => CourseContent.fromMap(e.key, e.value as Map<String, dynamic>))
        .toList();
    return CourseSection(
      id: id,
      title: data['title'] as String? ?? '',
      contents: contents,
      // UI fields stay default (not stored in Firestore)
    );
  }

  /// Convert model → Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'contents': {for (var c in contents) c.id: c.toMap()},
    };
  }
}
