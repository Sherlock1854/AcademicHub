// lib/quizzes/views/quizzes_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'quiz_attempt_page.dart';

class QuizzesPageScreen extends StatefulWidget {
  const QuizzesPageScreen({Key? key}) : super(key: key);

  @override
  State<QuizzesPageScreen> createState() => _QuizzesPageScreenState();
}

class _QuizzesPageScreenState extends State<QuizzesPageScreen> {
  late Future<List<Quiz>> _quizzesFut;

  @override
  void initState() {
    super.initState();
    _quizzesFut = QuizService.instance.fetchQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Quizzes')),
      bottomNavigationBar:
      const AppNavigationBar(selectedIndex: 2, isAdmin: false),
      body: FutureBuilder<List<Quiz>>(
        future: _quizzesFut,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizzes = snap.data ?? [];
          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes available.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final q = quizzes[i];
              return Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  dense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      q.coverUrl ??
                          'https://via.placeholder.com/80x80.png?text=No+Image',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[300], width: 56, height: 56),
                    ),
                  ),
                  title: Text(
                    q.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizAttemptPage(quizId: q.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
