// lib/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:academichub/course/models/course.dart';
import 'package:academichub/course/services/course_service.dart';
import 'package:academichub/course/views/course_detail_page.dart';
import 'package:academichub/bottom_nav.dart';

// These imports assume you have similar quiz classes/services
import 'package:academichub/quizzes/models/quiz.dart';
import 'package:academichub/quizzes/models/quiz_result.dart';
import 'package:academichub/quizzes/services/quiz_service.dart';
import 'package:academichub/quizzes/views/quiz_page.dart';
import 'package:academichub/quizzes/views/quiz_result_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: Text('Please sign in to see your dashboard.')),
        bottomNavigationBar: const AppNavigationBar(selectedIndex: 0, isAdmin: false),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // — Recently Joined Courses —
            _SectionTitle(title: 'Recently Joined Courses'),
            FutureBuilder<List<Course>>(
              future: CourseService.instance.fetchJoined(userId: user.uid),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final courses = snap.data ?? [];
                if (courses.isEmpty) {
                  return TextButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text('Browse Courses'),
                    onPressed: () => Navigator.pushNamed(context, '/courses'),
                  );
                }
                return SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final c = courses[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailPage(course: c),
                          ),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: c.thumbnailUrl != null
                                  ? Image.network(c.thumbnailUrl!,
                                  width: 80, height: 60, fit: BoxFit.cover)
                                  : const Icon(Icons.book, size: 60),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 80,
                              child: Text(
                                c.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // — Joined Quizzes —
            _SectionTitle(title: 'My Quizzes'),
            FutureBuilder<List<Quiz>>(
              future: QuizService.instance.fetchJoinedQuizzes(userId: user.uid),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final quizzes = snap.data ?? [];
                if (quizzes.isEmpty) {
                  return TextButton.icon(
                    icon: const Icon(Icons.quiz),
                    label: const Text('Browse Quizzes'),
                    onPressed: () => Navigator.pushNamed(context, '/quizzes'),
                  );
                }
                return Column(
                  children: quizzes.map((q) {
                    return ListTile(
                      leading: const Icon(Icons.quiz_outlined),
                      title: Text(q.title),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizPage(quiz: q),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // — Recently Attempted Quizzes —
            _SectionTitle(title: 'Recent Quiz Results'),
            FutureBuilder<List<QuizResult>>(
              future: QuizService.instance.fetchAttemptedQuizzes(userId: user.uid),
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final results = snap.data ?? [];
                if (results.isEmpty) {
                  return const Center(child: Text('No quiz attempts yet.'));
                }
                return Column(
                  children: results.map((r) {
                    return ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(r.title),
                      subtitle: Text('Score: ${r.score.toStringAsFixed(1)}%'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizResultPage(result: r),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(
        selectedIndex: 0, // 0 = Dashboard
        isAdmin: false,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
