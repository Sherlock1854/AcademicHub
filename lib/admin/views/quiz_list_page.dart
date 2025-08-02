// lib/admin/views/quiz_list_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'quiz_editor_page.dart';

const Color functionBlue = Color(0xFF006FF9);

class QuizListPage extends StatefulWidget {
  final String? courseId;
  const QuizListPage({Key? key, this.courseId}) : super(key: key);

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  late Future<List<Quiz>> _quizzes;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzes = QuizService.instance.fetchQuizzes(courseId: widget.courseId);
  }

  void _goToEditor({Quiz? quiz}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizEditorPage(
          courseId: widget.courseId,
          existing: quiz,
        ),
      ),
    );
    if (result == true) setState(_loadQuizzes);
  }

  void _confirmDelete(String quizId) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: functionBlue,
              side: const BorderSide(color: functionBlue),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: () async {
              Navigator.pop(context, true);
              await QuizService.instance.deleteQuiz(quizId);
              setState(_loadQuizzes);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Quizzes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,  // normal weight
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),
      ),
      bottomNavigationBar:
      const AppNavigationBar(selectedIndex: 1, isAdmin: true),
      body: FutureBuilder<List<Quiz>>(
        future: _quizzes,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizzes = snap.data ?? [];
          if (quizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "No quizzes created yet.",
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _goToEditor(),
                    icon: const Icon(Icons.add, color: functionBlue),
                    label: const Text(
                      "Create Quiz",
                      style: TextStyle(color: functionBlue),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: functionBlue),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final q = quizzes[i];
              return ListTile(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: q.coverUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    q.coverUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image,
                          size: 24, color: Colors.grey),
                    ),
                  ),
                )
                    : Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child:
                  const Icon(Icons.image, color: Colors.grey, size: 28),
                ),
                title: Text(
                  q.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.black),
                ),
                subtitle: q.courseId != null
                    ? Text(q.courseId!,
                    style: const TextStyle(color: Colors.black54))
                    : null,
                onTap: () => _goToEditor(quiz: q),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: functionBlue),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _goToEditor(quiz: q);
                    } else if (value == 'delete') {
                      _confirmDelete(q.id);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Quiz>>(
        future: _quizzes,
        builder: (context, snap) {
          final quizzes = snap.data ?? [];
          if (snap.connectionState == ConnectionState.done &&
              quizzes.isNotEmpty) {
            return FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: functionBlue,
              onPressed: () => _goToEditor(),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
