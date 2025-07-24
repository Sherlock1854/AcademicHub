// lib/course/views/course_content.dart

import 'package:flutter/material.dart';

class CourseContentScreen extends StatefulWidget {
  const CourseContentScreen({super.key});

  @override
  State<CourseContentScreen> createState() => _CourseContentScreenState();
}

class _CourseContentScreenState extends State<CourseContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Color primaryColor = const Color(0xFF3366FF);
  final Color backgroundColor = const Color(0xFFF5F2FA);

  // ─── Sample data with sections ─────────────────────────────────────────────
  final List<_ContentSection> _lectureSections = [
    _ContentSection(
      title: 'Section 1 - Course Introduction',
      items: [
        _ContentItemData(title: 'Welcome To This Course', type: 'Video', duration: '00:58'),
        _ContentItemData(title: 'READ BEFORE YOU START!', type: 'Article'),
        _ContentItemData(title: 'E-Book Resources 2.0', type: 'Article'),
      ],
    ),
    _ContentSection(
      title: 'Section 2 - The 25+ Guidelines Of Amazing Web Design',
      items: [
        _ContentItemData(title: 'Introduction To Web Design', type: 'Video', duration: '00:29'),
        _ContentItemData(title: 'Beautiful Typography', type: 'Video', duration: '08:53'),
      ],
    ),
  ];

  final List<_ContentSection> _quizSections = [
    _ContentSection(
      title: 'Section 1 - Basics',
      items: [
        _ContentItemData(title: 'Quiz 1: Typography Basics', type: 'Quiz'),
        _ContentItemData(title: 'Quiz 2: Layout and Spacing', type: 'Quiz'),
      ],
    ),
  ];
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Course Content',
          style: TextStyle(color: Colors.black),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: 'Lectures'),
            Tab(text: 'Quizzes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSectionedTab(_lectureSections),
          _buildSectionedTab(_quizSections),
        ],
      ),
    );
  }

  Widget _buildSectionedTab(List<_ContentSection> sections) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, sIndex) {
        final section = sections[sIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with expand icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.expand_more, color: Colors.grey),
                  onPressed: () {
                    // Toggle collapse/expand behavior if needed
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Section items
            ...section.items.map((item) {
              return CourseItem(
                title: item.title,
                type: item.type,
                duration: item.duration,
              );
            }).toList(),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

/// Internal model for a section
class _ContentSection {
  final String title;
  final List<_ContentItemData> items;
  _ContentSection({required this.title, required this.items});
}

/// Internal model for each item
class _ContentItemData {
  final String title;
  final String type;
  final String? duration;
  _ContentItemData({required this.title, required this.type, this.duration});
}

/// Reusable item tile
class CourseItem extends StatelessWidget {
  final String title;
  final String type;
  final String? duration;

  const CourseItem({
    super.key,
    required this.title,
    required this.type,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case 'Video':
        icon = Icons.play_circle_outline;
        break;
      case 'Article':
        icon = Icons.article_outlined;
        break;
      case 'Quiz':
        icon = Icons.quiz_outlined;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF3366FF)),
        title: Text(title),
        subtitle: Text(
          duration != null ? '$type • $duration mins' : type,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to video player, article view, or quiz
        },
      ),
    );
  }
}
