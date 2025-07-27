// lib/admin/services/quiz_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';

class QuizService {
  QuizService._();
  static final QuizService instance = QuizService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all quizzes, or only those for a given courseId.
  Future<List<Quiz>> fetchQuizzes({String? courseId}) async {
    Query query = _firestore.collection('quizzes');
    if (courseId != null) {
      query = query.where('courseId', isEqualTo: courseId);
    }
    final snap = await query.get();
    return snap.docs.map((doc) => Quiz.fromDoc(doc)).toList();
  }

  /// Create a new quiz, returning its ID.
  /// If coverUrl is provided, it will be stored alongside title & courseId.
  Future<String> addQuiz({
    String? courseId,
    required String title,
    String? coverUrl,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'courseId': courseId,
      if (coverUrl != null) 'coverUrl': coverUrl,
    };
    final ref = await _firestore.collection('quizzes').add(data);
    return ref.id;
  }

  /// Add a question document to a quiz’s subcollection.
  Future<void> addQuestion(String quizId, QuizQuestion question) async {
    await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .add(question.toMap());
  }

  /// Fetch all questions for a given quiz.
  Future<List<QuizQuestion>> fetchQuestions(String quizId) async {
    final snap = await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .get();
    return snap.docs.map((doc) => QuizQuestion.fromDoc(doc)).toList();
  }

  /// Update a quiz’s metadata: title, courseId, and/or coverUrl.
  Future<void> updateQuiz(
      String quizId, {
        String? title,
        String? courseId,
        String? coverUrl,
      }) async {
    final data = <String, dynamic>{};
    if (title != null)    data['title']     = title;
    if (courseId != null) data['courseId']  = courseId;
    if (coverUrl != null) data['coverUrl']  = coverUrl;
    if (data.isNotEmpty) {
      await _firestore.collection('quizzes').doc(quizId).update(data);
    }
  }

  /// Remove all existing questions under a quiz.
  Future<void> clearQuestions(String quizId) async {
    final questionsRef = _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions');
    final snap = await questionsRef.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  /// Delete a quiz and all of its questions.
  Future<void> deleteQuiz(String quizId) async {
    final quizRef = _firestore.collection('quizzes').doc(quizId);
    final questionsSnap = await quizRef.collection('questions').get();
    for (final doc in questionsSnap.docs) {
      await doc.reference.delete();
    }
    await quizRef.delete();
  }

  /// Update a single question in a quiz.
  Future<void> updateQuestion(
      String quizId,
      String questionId,
      QuizQuestion updated,
      ) async {
    await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .doc(questionId)
        .update(updated.toMap());
  }

  /// Delete a single question from a quiz.
  Future<void> deleteQuestion(String quizId, String questionId) async {
    await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }
}
