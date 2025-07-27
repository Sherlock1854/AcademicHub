import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttempt {
  final String id;
  final String quizId;
  final DateTime timestamp;
  final int score;
  final int total;
  final Map<String,int> answers;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.timestamp,
    required this.score,
    required this.total,
    required this.answers,
  });

  factory QuizAttempt.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String,dynamic>;
    return QuizAttempt(
      id:        doc.id,
      quizId:    data['quizId']    as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      score:     data['score']     as int,
      total:     data['total']     as int,
      answers:   Map<String,int>.from(data['answers'] as Map),
    );
  }
}
