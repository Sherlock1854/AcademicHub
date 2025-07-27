// lib/course/models/course_content.dart

class CourseContent {
  final String id;
  final String title;
  final String type;
  final String url;    // renamed from `value` to `url`
  final int order;

  CourseContent({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.order,
  });

  factory CourseContent.fromMap(Map<String, dynamic> map, String docId) {
    return CourseContent(
      id: docId,
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      url: map['url'] ?? '',       // read from `url`
      order: map['order'] ?? 0,
    );
  }
}
