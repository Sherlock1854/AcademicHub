import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_block.dart';

class QuizQuestion {
  final String id;
  final List<QuestionBlock> blocks;
  final List<String> choices;
  final int correctIndex;

  QuizQuestion({
    required this.id,
    required this.blocks,
    required this.choices,
    required this.correctIndex,
  });

  factory QuizQuestion.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizQuestion(
      id: doc.id,
      blocks: (data['blocks'] as List)
          .map((b) => QuestionBlock.fromMap(b))
          .toList(),
      choices: List<String>.from(data['choices']),
      correctIndex: data['correctIndex'],
    );
  }

  Map<String, dynamic> toMap() => {
    'blocks': blocks.map((b) => b.toMap()).toList(),
    'choices': choices,
    'correctIndex': correctIndex,
  };
}
