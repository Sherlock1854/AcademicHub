// lib/quizzes/views/quiz_attempt_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';
import 'quiz_question_page.dart';

const Color functionBlue = Color(0xFF006FF9);

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
      appBar: AppBar(
        title: const Text(
          'Attempt Quiz',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),
      ),
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
                  if (quiz.coverUrl != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          quiz.coverUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Total Questions: ${questions.length}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40), // reduced gap
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 200,
                        child: OutlinedButton(
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
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: functionBlue,
                            side: const BorderSide(color: functionBlue),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Attempt Quiz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500, // less bold
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 0), // spacing below button
                ],
              );
            },
          );
        },
      ),
    );
  }
}
