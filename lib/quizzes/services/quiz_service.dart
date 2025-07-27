import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';

class QuizService {
  QuizService._privateConstructor();
  static final QuizService instance = QuizService._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Quiz>> fetchQuizzes({String? courseId}) async {
    Query q = _firestore.collection('quizzes');
    if (courseId != null) q = q.where('courseId', isEqualTo: courseId);
    final snap = await q.get();
    return snap.docs.map((d) => Quiz.fromDoc(d)).toList();
  }

  Future<List<QuizQuestion>> fetchQuestions(String quizId) async {
    final snap = await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .get();
    return snap.docs.map((d) => QuizQuestion.fromDoc(d)).toList();
  }

  Future<void> deleteQuiz(String quizId) async {
    // Delete sub-collection
    final questions = await _firestore
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .get();
    for (final doc in questions.docs) {
      await doc.reference.delete();
    }
    // Delete quiz doc
    await _firestore.collection('quizzes').doc(quizId).delete();
  }

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
