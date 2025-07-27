import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/course_content.dart';

class CourseService {
  CourseService._();
  static final instance = CourseService._();
  final _db = FirebaseFirestore.instance;

  /// Fetch all unique course categories
  Future<List<String>> fetchCategories() async {
    final snapshot = await _db.collection('courses').get();
    final categories = snapshot.docs
        .map((doc) => doc['category'] as String)
        .toSet()
        .toList();
    return categories;
  }

  /// Fetch courses for a given category, sorted by latest
  Future<List<Course>> fetchCoursesByCategory(String category) async {
    debugPrint("Fetching courses for category: $category");
    final snapshot = await _db
        .collection('courses')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .get();

    debugPrint("Documents found: ${snapshot.docs.length}");
    return snapshot.docs.map((doc) {
      debugPrint("Course found: ${doc.data()}");
      return Course.fromMap(doc.data(), doc.id);
    }).toList();
  }

  /// (Optional legacy) Fetch contents subcollection for a course
  Future<List<CourseContent>> fetchCourseContent(String courseId) async {
    final snapshot = await _db
        .collection('courses')
        .doc(courseId)
        .collection('Contents')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => CourseContent.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Join a course (write to Users/{userId}/JoinedCourses/{courseId})
  Future<void> joinCourse(String userId, String courseId) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('JoinedCourses')
        .doc(courseId)
        .set({
      'courseId': courseId,
      'joinedAt': Timestamp.now(),
    });
  }

  /// Fetch all courses that a user has joined
  Future<List<Course>> fetchJoined({required String userId}) async {
    final joinedSnapshot = await _db
        .collection('Users')
        .doc(userId)
        .collection('JoinedCourses')
        .get();

    final courseIds = joinedSnapshot.docs.map((doc) => doc.id).toList();

    if (courseIds.isEmpty) return [];

    final coursesSnapshot = await _db
        .collection('courses')
        .where(FieldPath.documentId, whereIn: courseIds)
        .get();

    return coursesSnapshot.docs
        .map((doc) => Course.fromMap(doc.data(), doc.id))
        .toList();
  }
}
