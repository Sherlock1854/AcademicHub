enum ContentType { video, article }

extension ContentTypeExtension on ContentType {
  String get name {
    switch (this) {
      case ContentType.video:   return 'video';
      case ContentType.article: return 'article';
    }
  }
}

class CourseContent {
  final String id;
  final ContentType type;
  final String url;    // for video: URL or storage link; for article: prefixed "text:..."
  final String title;

  CourseContent({
    required this.id,
    required this.type,
    required this.url,
    required this.title,
  });

  factory CourseContent.fromMap(String id, Map<String, dynamic> data) {
    final rawType = data['type'] as String? ?? 'article';
    final type = ContentType.values.firstWhere(
          (e) => e.name == rawType,
      orElse: () => ContentType.article,
    );
    return CourseContent(
      id:    id,
      type:  type,
      url:   data['url'] as String,
      title: data['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'type':  type.name,
    'url':   url,
    'title': title,
  };
}
