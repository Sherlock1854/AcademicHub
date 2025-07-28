import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:academichub/course/models/course.dart';
import 'package:academichub/course/services/course_service.dart';
import 'package:academichub/course/views/course_content_page.dart';
import 'package:academichub/bottom_nav.dart';

import 'package:academichub/quizzes/models/quiz_attempt.dart';
import 'package:academichub/quizzes/services/quiz_attempt_service.dart';
import 'package:academichub/quizzes/models/quiz.dart';
import '../../friend/views/friends_screen.dart';
import '../../notification/views/notifications_screen.dart';

const Color functionBlue = Color(0xFF006FF9);

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => NotificationsScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const FriendsScreen(),
              ));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to see your dashboard.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Recently Joined Courses'),
            _JoinedCoursesList(userId: user.uid),
            const SizedBox(height: 32),
            const _SectionTitle('Your Quiz Results'),
            _QuizResultsList(),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 0, isAdmin: false),
    );
  }
}

class _JoinedCoursesList extends StatelessWidget {
  final String userId;
  const _JoinedCoursesList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: CourseService.instance.fetchJoined(userId: userId),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Text('Error loading courses:\n${snap.error}',
              style: const TextStyle(color: Colors.red));
        }
        final courses = snap.data ?? [];
        if (courses.isEmpty) {
          return Center(
            child: TextButton.icon(
              icon: const Icon(Icons.search, color: functionBlue),
              label: const Text('Browse Courses', style: TextStyle(color: functionBlue)),
              onPressed: () => Navigator.pushNamed(context, '/courses'),
            ),
          );
        }
        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = courses[i];
              return _CourseCardWithProgress(
                course: c,
                userId: userId,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseContentPage(courseId: c.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _QuizResultsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuizAttempt>>(
      future: QuizAttemptService.instance.fetchMyResults(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Text('Error loading quiz results:\n${snap.error}',
              style: const TextStyle(color: Colors.red));
        }
        final attempts = snap.data ?? [];
        if (attempts.isEmpty) {
          return const Center(child: Text('You haven’t taken any quizzes yet.'));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: attempts.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, idx) {
            final qa = attempts[idx];
            final pct = qa.total > 0 ? qa.score / qa.total : 0.0;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('quizzes')
                  .doc(qa.quizId)
                  .get(),
              builder: (ctx2, quizSnap) {
                Widget leading;
                String titleText;

                if (quizSnap.connectionState != ConnectionState.done) {
                  leading = const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                  titleText = 'Loading quiz…';
                } else if (!quizSnap.hasData || !quizSnap.data!.exists) {
                  leading = const Icon(Icons.quiz, size: 48, color: functionBlue);
                  titleText = 'Unknown Quiz';
                } else {
                  final quiz = Quiz.fromDoc(quizSnap.data!);
                  leading = quiz.coverUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      quiz.coverUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(Icons.quiz, size: 48, color: functionBlue);
                  titleText = quiz.title;
                }

                return ListTile(
                  leading: leading,
                  title: Text(titleText),
                  subtitle: Text(
                    'Score: ${qa.score}/${qa.total} (${(pct * 100).toStringAsFixed(0)}%)',
                  ),
                  trailing: Text(
                    _formatTimestamp(qa.timestamp),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {},
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    const mons = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '$h:$m · ${mons[dt.month]} ${dt.day}';
  }
}

class _CourseCardWithProgress extends StatelessWidget {
  final Course course;
  final String userId;
  final VoidCallback onTap;

  const _CourseCardWithProgress({
    required this.course,
    required this.userId,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: CourseService.instance.fetchProgressForCourse(
        userId: userId,
        course: course,
      ),
      builder: (ctx, snap) {
        double percent = 0;
        if (snap.hasData && snap.data!['total']! > 0) {
          percent = snap.data!['viewed']! / snap.data!['total']!;
        }
        final label = snap.hasData && snap.data!['total']! > 0
            ? '${(percent * 100).toStringAsFixed(0)}% viewed'
            : '';

        return GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 140,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          course.thumbnailUrl!,
                          width: 80,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Icon(Icons.book, size: 60, color: functionBlue),
                    const SizedBox(height: 6),
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (label.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percent,
                        minHeight: 6,
                        valueColor: const AlwaysStoppedAnimation(functionBlue),
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Text(label,
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
