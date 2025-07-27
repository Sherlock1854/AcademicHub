// lib/admin/services/admin_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/course.dart';

class AdminService {
  AdminService._();
  static final instance = AdminService._();

  final _col = FirebaseFirestore.instance.collection('courses');
  final _storage = FirebaseStorage.instance;

  Stream<List<Course>> coursesStream() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => Course.fromDoc(d)).toList());

  Future<void> deleteCourse(String id) => _col.doc(id).delete();

  Future<void> createCourse(Course course, {File? thumbnailFile}) async {
    final doc = _col.doc();
    String? thumbUrl = course.thumbnailUrl;
    if (thumbnailFile != null) {
      final ref = _storage.ref('courses/${doc.id}/thumbnail.jpg');
      final task = await ref.putFile(thumbnailFile);
      thumbUrl = await task.ref.getDownloadURL();
    }
    await doc.set({
      ...course.toMap(),
      'thumbnailUrl': thumbUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Return all courses with the given category.
  Future<List<Course>> getCoursesByCategory(String category) async {
    final snap = await _col.where('category', isEqualTo: category).get();
    return snap.docs.map((d) => Course.fromDoc(d)).toList();
  }

  Future<void> updateCourse(Course course, {File? thumbnailFile}) async {
    final doc = _col.doc(course.id);
    String? thumbUrl = course.thumbnailUrl;
    if (thumbnailFile != null) {
      final ref = _storage.ref('courses/${course.id}/thumbnail.jpg');
      final task = await ref.putFile(thumbnailFile);
      thumbUrl = await task.ref.getDownloadURL();
    }
    await doc.update({
      'title'       : course.title,
      'description' : course.description,
      'category'    : course.category,
      'thumbnailUrl': thumbUrl,
      'sections'    : course.sections.map((s) => s.toMap()).toList(),
    });
  }
}
