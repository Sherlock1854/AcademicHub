// lib/quizzes/views/quizzes_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'quiz_attempt_page.dart';

const Color functionBlue = Color(0xFF006FF9);

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
      appBar: AppBar(
        title: const Text(
          'Quizzes',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),
      ),
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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final q = quizzes[i];
              return SizedBox(
                height: 100,
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        q.coverUrl ??
                            'https://via.placeholder.com/80x80.png?text=No+Image',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[300], width: 64, height: 64),
                      ),
                    ),
                    title: Text(
                      q.title,
                      style: const TextStyle(
                        fontSize: 18,       // match Course list title size
                        fontWeight: FontWeight.w500, // match Course list weight
                        color: Colors.black,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: functionBlue,
                      size: 20,
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
