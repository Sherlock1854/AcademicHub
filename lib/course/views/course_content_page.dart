// lib/course/views/course_content_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/course.dart';
import '../models/course_content.dart';

class CourseContentPage extends StatefulWidget {
  final String courseId;
  const CourseContentPage({Key? key, required this.courseId})
      : super(key: key);

  @override
  State<CourseContentPage> createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  Course? _course;
  CourseContent? _selected;
  YoutubePlayerController? _ytController;
  String? _articleText;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCourse();
  }

  Future<void> _loadCourse() async {
    final doc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .get();
    if (!doc.exists) throw 'Course not found';
    final course = Course.fromMap(doc.data()!, doc.id);

    // pick first content if available
    CourseContent? first;
    if (course.sections.isNotEmpty) {
      final sec0 = course.sections[0] as Map<String, dynamic>;
      final raw = sec0['contents'];
      final list = raw is List
          ? raw
          : (raw as Map<String, dynamic>)
          .entries
          .map((e) => e.value)
          .toList();
      if (list.isNotEmpty) {
        final m = Map<String, dynamic>.from(list.first as Map);
        final id = (m['id'] as String?) ?? '0-0';
        first = CourseContent.fromMap(m, id);
      }
    }

    // initialize everything before we rebuild once
    if (first != null) {
      _initSelected(first);
    }

    setState(() {
      _course = course;
      _selected = first;
      _loading = false;
    });
  }

  void _initSelected(CourseContent content) {
    // dispose old
    _ytController?.dispose();
    _ytController = null;
    _articleText = null;

    if (content.type.toLowerCase() == 'video') {
      final vid = YoutubePlayer.convertUrlToId(content.url) ?? '';
      _ytController = YoutubePlayerController(
        initialVideoId: vid,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    } else {
      _articleText = content.url.startsWith('text:')
          ? content.url.substring(5)
          : content.url;
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final sections = _course!.sections;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Contents'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            // ─── Top area ───
            if (_selected != null && _ytController != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: YoutubePlayer(
                    controller: _ytController!,
                    showVideoProgressIndicator: true,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_selected != null && _articleText != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  height: 200,
                  child: SingleChildScrollView(
                    child: Text(
                      _articleText!,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Pills list ───
            Expanded(
              child: ListView.builder(
                itemCount: sections.length,
                itemBuilder: (ctx, sIndex) {
                  final secMap =
                  Map<String, dynamic>.from(sections[sIndex] as Map);
                  final sectionTitle = secMap['title'] as String? ?? '';
                  final raw = secMap['contents'];
                  final contents = raw is List
                      ? raw
                      : (raw as Map<String, dynamic>)
                      .entries
                      .map((e) => e.value)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Text(
                        sectionTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),

                      // Section contents
                      for (var cIndex = 0;
                      cIndex < contents.length;
                      cIndex++) ...[
                        Builder(builder: (_) {
                          final m =
                          Map<String, dynamic>.from(contents[cIndex] as Map);
                          final id =
                              (m['id'] as String?) ?? '$sIndex-$cIndex';
                          final content =
                          CourseContent.fromMap(m, id);
                          final isVideo =
                              content.type.toLowerCase() == 'video';

                          return InkWell(
                            onTap: () {
                              _initSelected(content);
                              setState(() => _selected = content);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isVideo
                                        ? Icons.play_circle_fill
                                        : Icons.article_outlined,
                                    size: 20,
                                    color: isVideo
                                        ? Colors.deepPurple
                                        : Colors.blueGrey,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      content.title,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
