import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz_attempt.dart';

class QuizAttemptService {
  QuizAttemptService._();
  static final QuizAttemptService instance = QuizAttemptService._();

  final _firestore = FirebaseFirestore.instance;

  Future<void> recordAttempt({
    required String quizId,
    required int score,
    required int total,
    required Map<String,int> answers,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError("Must be signed in.");

    await _firestore
        .collection('Users')
        .doc(uid)
        .collection('results')
        .add({
      'quizId':    quizId,
      'timestamp': FieldValue.serverTimestamp(),
      'score':     score,
      'total':     total,
      'answers':   answers,
    });
  }

  Future<List<QuizAttempt>> fetchMyResults() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final snap = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('results')
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) => QuizAttempt.fromDoc(d)).toList();
  }
}
