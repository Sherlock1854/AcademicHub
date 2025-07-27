// lib/course/views/course_detail_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:academichub/course/models/course.dart';
import 'package:academichub/course/services/course_service.dart';

const Color functionBlue = Color(0xFF006FF9);

class CourseDetailPage extends StatefulWidget {
  final Course course;
  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _joining = false;

  Future<void> _handleJoin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _joining = true);

    final userId = user.uid;
    final courseId = widget.course.id;

    final docRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('JoinedCourses')
        .doc(courseId);

    if ((await docRef.get()).exists) {
      setState(() => _joining = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You’ve already joined this course.')),
      );
      return;
    }

    await CourseService.instance.joinCourse(userId, courseId);

    setState(() => _joining = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully joined the course!')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final sections = course.sections;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          course.title,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),  // back arrow
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          if (course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                course.thumbnailUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(course.category,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(course.title,
              style:
              const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(course.description,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 16),
          const Divider(),
          for (var sIndex = 0; sIndex < sections.length; sIndex++) ...[
            Builder(builder: (_) {
              final secMap =
              Map<String, dynamic>.from(sections[sIndex] as Map);
              final sectionTitle = secMap['title'] as String? ?? 'Untitled';
              final raw = secMap['contents'];
              final contents = raw is List
                  ? raw
                  : (raw as Map<String, dynamic>)
                  .entries
                  .map((e) => e.value)
                  .toList();

              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sectionTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    for (var cIndex = 0; cIndex < contents.length; cIndex++) ...[
                      Builder(builder: (_) {
                        final cMap =
                        Map<String, dynamic>.from(contents[cIndex] as Map);
                        final title = cMap['title'] as String? ?? '';
                        final type =
                        (cMap['type'] as String? ?? '').toLowerCase();
                        final isVideo = type == 'video';

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isVideo
                                    ? Icons.play_circle_fill
                                    : Icons.article,
                                size: 20,
                                color: functionBlue,  // always blue
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(title,
                                    style: const TextStyle(fontSize: 14)),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _joining
            ? const Center(child: CircularProgressIndicator(color: functionBlue))
            : OutlinedButton(
          onPressed: _handleJoin,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: functionBlue,
            side: const BorderSide(color: functionBlue),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Join Course',
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
