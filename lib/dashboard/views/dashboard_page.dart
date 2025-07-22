import 'package:flutter/material.dart';
import '../../bottom_nav.dart';
import 'widget/course_card.dart';
import '../../course/views/course_page.dart';
import '../../course/services/course_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late List<CourseModel> joinedCourses;

  @override
  void initState() {
    super.initState();
    joinedCourses = CourseService().getJoinedCourses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh joined courses when coming back from course page
    setState(() {
      joinedCourses = CourseService().getJoinedCourses();
    });
  }

  void _navigateToJoinCourse() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CoursesPageScreen()),
    );

    // After returning, refresh the joined courses
    setState(() {
      joinedCourses = CourseService().getJoinedCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Courses',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
            onPressed: () {
              debugPrint('Notifications tapped');
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
            onPressed: () {
              debugPrint('Chat tapped');
            },
          ),
        ],
      ),
      body: joinedCourses.isEmpty
          ? Center(
        child: ElevatedButton.icon(
          onPressed: _navigateToJoinCourse,
          icon: const Icon(Icons.add),
          label: const Text('Join a Course'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: joinedCourses.length,
        itemBuilder: (context, index) {
          final course = joinedCourses[index];
          return CourseCard(
            courseTitle: course.title,
            courseSubtitle: course.subtitle,
            teacherInitial: course.instructor.isNotEmpty
                ? course.instructor[0].toUpperCase()
                : '?',
          );
        },
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 0),
    );
  }
}
