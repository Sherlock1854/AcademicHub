// lib/quizzes/views/quiz_attempt_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';

// ← import your question page
import 'quiz_question_page.dart';

class QuizAttemptPage extends StatefulWidget {
  final String quizId;

  const QuizAttemptPage({Key? key, required this.quizId}) : super(key: key);

  @override
  State<QuizAttemptPage> createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> {
  late Future<Quiz> _quizFut;
  late Future<List<QuizQuestion>> _questionsFut;

  @override
  void initState() {
    super.initState();
    _quizFut = FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .get()
        .then((doc) => Quiz.fromDoc(doc));
    _questionsFut = QuizService.instance.fetchQuestions(widget.quizId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take Quiz')),
      body: FutureBuilder<Quiz>(
        future: _quizFut,
        builder: (ctx, quizSnap) {
          if (quizSnap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!quizSnap.hasData) {
            return const Center(child: Text('Quiz not found.'));
          }
          final quiz = quizSnap.data!;
          return FutureBuilder<List<QuizQuestion>>(
            future: _questionsFut,
            builder: (ctx2, qSnap) {
              if (qSnap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final questions = qSnap.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      quiz.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Cover
                  if (quiz.coverUrl != null) ...[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            quiz.coverUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Total Questions: ${questions.length}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  // ← UPDATED START BUTTON
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: questions.isEmpty
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizQuestionsPage(
                              quizId: widget.quizId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48)),
                      child: const Text(
                        'Start Quiz',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
