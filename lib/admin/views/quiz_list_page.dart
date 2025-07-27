import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import 'quiz_editor_page.dart';
import 'package:academichub/bottom_nav.dart';

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
    final result = await Navigator.push(
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this quiz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await QuizService.instance.deleteQuiz(quizId);
              setState(_loadQuizzes);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseId != null ? 'Course Quizzes' : 'All Quizzes'),
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 2, isAdmin: true),
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
                  const Text("No quizzes created yet.", style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _goToEditor(),
                    icon: const Icon(Icons.add),
                    label: const Text("Create Quiz"),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: const Icon(Icons.broken_image, size: 24),
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
                  child: const Icon(Icons.image, color: Colors.grey, size: 28),
                ),
                title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: q.courseId != null
                    ? Text(q.courseId!, style: const TextStyle(color: Colors.black54))
                    : null,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _goToEditor(quiz: q);
                    } else if (value == 'delete') {
                      _confirmDelete(q.id);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
                onTap: () => _goToEditor(quiz: q),
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Quiz>>(
        future: _quizzes,
        builder: (context, snap) {
          final quizzes = snap.data ?? [];
          if (snap.connectionState == ConnectionState.done && quizzes.isNotEmpty) {
            return FloatingActionButton(
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
