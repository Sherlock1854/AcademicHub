import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';
import '../models/course_content.dart';

class CourseService {
  CourseService._();
  static final instance = CourseService._();
  final _db = FirebaseFirestore.instance;

  /// Fetch all unique course categories
  Future<List<String>> fetchCategories() async {
    final snapshot = await _db.collection('courses').get();
    return snapshot.docs
        .map((doc) => doc['category'] as String)
        .toSet()
        .toList();
  }

  /// Fetch courses for a given category
  Future<List<Course>> fetchCoursesByCategory(String category) async {
    final snap = await _db
        .collection('courses')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => Course.fromMap(d.data(), d.id))
        .toList();
  }

  /// Join a course (status=registered)
  Future<void> joinCourse(String userId, String courseId) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('JoinedCourses')
        .doc(courseId)
        .set({
      'courseId': courseId,
      'joinedAt': Timestamp.now(),
      'status': 'registered',
    }, SetOptions(merge: true));
  }

  /// Mark a joined course as finished
  Future<void> markCourseAsFinished(String userId, String courseId) async {
    await _db
        .collection('Users')
        .doc(userId)
        .collection('JoinedCourses')
        .doc(courseId)
        .set({
      'status': 'finished',
      'finishedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Fetch all courses that a user has joined
  Future<List<Course>> fetchJoined({required String userId}) async {
    final js = await _db
        .collection('Users')
        .doc(userId)
        .collection('JoinedCourses')
        .get();
    final ids = js.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];
    final cs = await _db
        .collection('courses')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return cs.docs.map((d) => Course.fromMap(d.data(), d.id)).toList();
  }

  /// Fetch which content IDs the user has viewed
  Future<List<String>> fetchCourseProgress({
    required String userId,
    required String courseId,
  }) async {
    final doc = await _db
        .collection('Users')
        .doc(userId)
        .collection('CourseProgress')
        .doc(courseId)
        .get();
    if (!doc.exists) return [];
    final data = doc.data();
    if (data == null || data['viewedContentIds'] == null) return [];
    return List<String>.from(data['viewedContentIds']);
  }

  /// Track one piece of content as viewed (and auto-finish course when done)
  Future<void> trackContentViewed({
    required String userId,
    required String courseId,
    required String contentId,
  }) async {
    // 1) add to viewedContentIds
    await _db
        .collection('Users')
        .doc(userId)
        .collection('CourseProgress')
        .doc(courseId)
        .set({
      'viewedContentIds': FieldValue.arrayUnion([contentId]),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));

    // 2) check for auto-finish
    final courseSnap = await _db.collection('courses').doc(courseId).get();
    final secs = courseSnap.data()!['sections'] as List<dynamic>;
    final allIds = <String>[];
    for (var s in secs) {
      final sec = Map<String, dynamic>.from(s as Map);
      final raw = sec['contents'];
      final list = raw is List
          ? raw
          : (raw as Map<String, dynamic>).entries.map((e) => e.value).toList();
      for (var c in list) {
        final m = Map<String, dynamic>.from(c as Map);
        final id = m['id'] as String? ?? '';
        allIds.add(id);
      }
    }
    final viewed = await fetchCourseProgress(userId: userId, courseId: courseId);
    if (viewed.toSet().containsAll(allIds.toSet())) {
      await markCourseAsFinished(userId, courseId);
    }
  }

  /// Shorthand: called by UI to mark content viewed
  Future<void> viewContent({
    required String courseId,
    required CourseContent content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await trackContentViewed(
      userId: user.uid,
      courseId: courseId,
      contentId: content.id,
    );
  }

  /// For Dashboard: total vs viewed count
  Future<Map<String,int>> fetchProgressForCourse({
    required String userId,
    required Course course,
  }) async {
    final viewed = await fetchCourseProgress(userId: userId, courseId: course.id);
    var total = 0;
    for (var s in course.sections) {
      final sec = Map<String,dynamic>.from(s as Map);
      final raw = sec['contents'];
      final list = raw is List
          ? raw
          : (raw as Map<String,dynamic>).entries.map((e)=>e.value).toList();
      total += list.length;
    }
    return {'viewed': viewed.length, 'total': total};
  }
}
