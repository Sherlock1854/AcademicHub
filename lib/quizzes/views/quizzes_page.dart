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
  late Future<List<Quiz>> _future;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initially load all quizzes
    _future = QuizService.instance.fetchQuizzes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final keyword = _searchController.text;
    setState(() {
      if (keyword.trim().isEmpty) {
        // reset to all quizzes
        _future = QuizService.instance.fetchQuizzes();
      } else {
        // perform case-insensitive substring search
        _future = QuizService.instance.searchQuizzes(keyword: keyword);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),
      ),
      bottomNavigationBar:
      const AppNavigationBar(selectedIndex: 2, isAdmin: false),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              cursorColor: functionBlue,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Search quizzes…',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: functionBlue),
                  onPressed: _onSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: functionBlue, width: 2),
                ),
              ),
            ),
          ),

          // Quiz list
          Expanded(
            child: FutureBuilder<List<Quiz>>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Error loading quizzes:\n${snap.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final quizzes = snap.data ?? [];
                if (quizzes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No quizzes found. Try another keyword.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.separated(
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  itemCount: quizzes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
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
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                width: 64,
                                height: 64,
                              ),
                            ),
                          ),
                          title: Text(
                            q.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
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
                                builder: (_) =>
                                    QuizAttemptPage(quizId: q.id),
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
          ),
        ],
      ),
    );
  }
}
