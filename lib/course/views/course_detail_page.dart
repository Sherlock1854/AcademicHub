import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:academichub/course/models/course.dart';
import 'package:academichub/course/services/course_service.dart';
import 'package:academichub/course/views/course_content_page.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;
  const CourseDetailPage({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _joining = false;

  Future<void> _handleJoin() async {
    setState(() => _joining = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    await CourseService.instance.joinCourse(userId, widget.course.id);
    setState(() => _joining = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully joined the course!')),
    );

    // now push into the CONTENT LIST page, not a single content
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseContentPage(courseId: widget.course.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final sections = course.sections; // List<dynamic>

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          // — Thumbnail —
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

          // — Metadata —
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

          // — Sections & Contents (tapping now also goes to the LIST page) —
          for (var sIndex = 0; sIndex < sections.length; sIndex++) ...[
            Builder(builder: (_) {
              final secMap =
              Map<String, dynamic>.from(sections[sIndex] as Map);
              final sectionTitle = secMap['title'] as String? ?? 'Untitled';

              // normalize
              final rawC = secMap['contents'];
              List<dynamic> contents;
              if (rawC is List) {
                contents = rawC;
              } else if (rawC is Map<String, dynamic>) {
                contents = rawC.entries.map((e) => e.value).toList();
              } else {
                contents = <dynamic>[];
              }

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

                        return InkWell(
                          onTap: () {
                            // **instead of passing content**, we go to the CONTENT LIST page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseContentPage(
                                    courseId: widget.course.id),
                              ),
                            );
                          },
                          child: Container(
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
                                  color: isVideo
                                      ? Colors.deepPurple
                                      : Colors.blueGrey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(title,
                                      style: const TextStyle(fontSize: 14)),
                                ),
                              ],
                            ),
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
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
          onPressed: _handleJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
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
