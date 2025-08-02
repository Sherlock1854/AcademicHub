// lib/quizzes/services/quiz_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';

class QuizService {
  QuizService._privateConstructor();
  static final QuizService instance = QuizService._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all quizzes, or only those for a given course.
  Future<List<Quiz>> fetchQuizzes({String? courseId}) async {
    Query q = _firestore.collection('quizzes');
    if (courseId != null) {
      q = q.where('courseId', isEqualTo: courseId);
    }
    final snap = await q.get();
    return snap.docs.map((d) => Quiz.fromDoc(d)).toList();
  }

  /// Search quizzes by title substring, case-insensitive.
  /// Optionally restrict to a course.
  Future<List<Quiz>> searchQuizzes({
    String? courseId,
    required String keyword,
  }) async {
    final trimmed = keyword.trim().toLowerCase();
    if (trimmed.isEmpty) return [];

    // Get base list
    final all = await fetchQuizzes(courseId: courseId);

    // Filter in Dart for titles containing the keyword
    return all
        .where((q) => q.title.toLowerCase().contains(trimmed))
        .toList();
  }

  /// Fetch all questions for a quiz.
  Future<List<QuizQuestion>> fetchQuestions(String quizId) async {
    final snap = await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .get();
    return snap.docs.map((d) => QuizQuestion.fromDoc(d)).toList();
  }

  /// Delete a quiz and all its questions.
  Future<void> deleteQuiz(String quizId) async {
    // Delete questions sub-collection
    final questions = await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .get();
    for (final doc in questions.docs) {
      await doc.reference.delete();
    }
    // Delete the quiz document
    await _firestore.collection('quizzes').doc(quizId).delete();
  }

  /// Update quiz metadata.
  Future<void> updateQuiz(
      String quizId, {
        String? title,
        String? coverUrl,
      }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (coverUrl != null) data['coverUrl'] = coverUrl;
    if (data.isNotEmpty) {
      await _firestore.collection('quizzes').doc(quizId).update(data);
    }
  }
}
