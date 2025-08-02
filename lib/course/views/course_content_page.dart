// lib/course/views/course_content_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';               // ← new
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/course.dart';
import '../models/course_content.dart';
import '../services/course_service.dart';

const Color functionBlue = Color(0xFF006FF9);

class CourseContentPage extends StatefulWidget {
  final String courseId;
  const CourseContentPage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CourseContentPage> createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  Course? _course;
  CourseContent? _selected;
  YoutubePlayerController? _ytController;
  String? _articleText;
  bool _loading = true;

  // ← holds the IDs of content the user has viewed
  List<String> _viewedContentIds = [];

  @override
  void initState() {
    super.initState();
    _loadCourseAndProgress();
  }

  Future<void> _loadCourseAndProgress() async {
    // 1️⃣ Load the course document
    final doc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .get();
    if (!doc.exists) throw 'Course not found';
    final course = Course.fromMap(doc.data()!, doc.id);

    // 2️⃣ Pick the first piece of content if available
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

    // 3️⃣ Load which content IDs the user has already viewed
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _viewedContentIds = await CourseService.instance.fetchCourseProgress(
        userId: user.uid,
        courseId: widget.courseId,
      );
    }

    setState(() {
      _course = course;
      _selected = first;
      _loading = false;
    });

    // 4️⃣ Initialize the first piece if there is one
    if (first != null) {
      _initSelected(first);
    }
  }

  void _initSelected(CourseContent content) {
    // dispose previous player
    _ytController?.dispose();
    _ytController = null;
    _articleText = null;

    // Mark this content as viewed, if not already
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !_viewedContentIds.contains(content.id)) {
      CourseService.instance
          .viewContent(courseId: widget.courseId, content: content)
          .then((_) {
        setState(() {
          _viewedContentIds.add(content.id);
        });
      });
    }

    // If it's a video, spin up the YoutubePlayer
    if (content.type.toLowerCase() == 'video') {
      final vid = YoutubePlayer.convertUrlToId(content.url) ?? '';
      _ytController = YoutubePlayerController(
        initialVideoId: vid,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    } else {
      // Otherwise assume it's an article
      _articleText = content.url.startsWith('text:')
          ? content.url.substring(5)
          : content.url;
    }

    setState(() => _selected = content);
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
        centerTitle: true,
        title: const Text(
          'Course Contents',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: functionBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            // Show video or article preview
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
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // List all sections and contents
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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sectionTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),

                        // Each content item
                        for (var cIndex = 0;
                        cIndex < contents.length;
                        cIndex++) ...[
                          Builder(builder: (_) {
                            final cMap =
                            Map<String, dynamic>.from(contents[cIndex] as Map);
                            final title = cMap['title'] as String? ?? '';
                            final type =
                            (cMap['type'] as String? ?? '').toLowerCase();
                            final isVideo = type == 'video';

                            // We use the same ID scheme: 'sectionIndex-contentIndex'
                            final contentId = '$sIndex-$cIndex';
                            final viewed =
                            _viewedContentIds.contains(contentId);

                            return InkWell(
                              onTap: () {
                                final selected = CourseContent.fromMap(
                                    cMap, contentId);
                                _initSelected(selected);
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
                                          : Icons.article_outlined,
                                      size: 20,
                                      color: functionBlue,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    // ← Check mark if already viewed
                                    if (viewed)
                                      const Icon(
                                        Icons.check_circle,
                                        color: functionBlue,
                                        size: 16,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
