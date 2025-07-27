import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String? courseId;
  final String? coverUrl;  // ← new

  Quiz({
    required this.id,
    required this.title,
    this.courseId,
    this.coverUrl,
  });

  factory Quiz.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Quiz(
      id: doc.id,
      title: data['title'] as String,
      courseId: data['courseId'] as String?,
      coverUrl: data['coverUrl'] as String?,  // ← new
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'courseId': courseId,
    'coverUrl': coverUrl,  // ← new
  };
}
