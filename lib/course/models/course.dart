import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final List<dynamic> sections;  // always non-null List

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.thumbnailUrl,
    required this.sections,
  });

  factory Course.fromMap(Map<String, dynamic> map, String docId) {
    // Pull raw data from Firestore
    final raw = map['sections'];

    // Normalize it to a List<dynamic>
    List<dynamic> sectionList;
    if (raw is List) {
      sectionList = raw;
    } else if (raw is Map<String, dynamic>) {
      // If you stored as a map of maps, drop the keys:
      sectionList = raw.entries.map((e) => e.value).toList();
    } else {
      sectionList = <dynamic>[];
    }

    return Course(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      thumbnailUrl: map['thumbnailUrl'],
      sections: sectionList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'thumbnailUrl': thumbnailUrl,
      'sections': sections,
    };
  }
}
