import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';  // for UniqueKey
import 'course_section.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? thumbnailUrl;
  final List<CourseSection> sections;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.thumbnailUrl,
    this.sections = const [],
  });

  factory Course.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawSecs = data['sections'];
    List<CourseSection> secs = [];

    if (rawSecs is Map<String, dynamic>) {
      // Old or admin‐written: map of maps
      secs = rawSecs.entries
          .map((e) =>
          CourseSection.fromMap(e.key, e.value as Map<String, dynamic>))
          .toList();
    } else if (rawSecs is List) {
      // Some docs wrote sections as a List<dynamic>
      secs = rawSecs.map((item) {
        if (item is Map<String, dynamic>) {
          // if your item has an 'id' field inside, use it; else generate one
          final id = item['id'] as String? ?? UniqueKey().toString();
          return CourseSection.fromMap(id, item);
        } else {
          // fallback empty section
          return CourseSection.empty(UniqueKey().toString());
        }
      }).toList();
    }

    return Course(
      id:          doc.id,
      title:       data['title']       as String? ?? '',
      description: data['description'] as String? ?? '',
      category:    data['category']    as String? ?? '',
      thumbnailUrl:data['thumbnailUrl']as String?,
      sections:    secs,
    );
  }

  Map<String, dynamic> toMap() => {
    'title'       : title,
    'description' : description,
    'category'    : category,
    'thumbnailUrl': thumbnailUrl,
    'sections'    : {for (var s in sections) s.id: s.toMap()},
    'createdAt'   : FieldValue.serverTimestamp(),
  };
}
