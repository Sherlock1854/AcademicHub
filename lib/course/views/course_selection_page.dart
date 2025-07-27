// lib/course/views/course_selection_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/course/models/course.dart';
import 'package:academichub/course/services/course_service.dart';
import 'package:academichub/course/views/course_detail_page.dart';
import 'package:academichub/bottom_nav.dart';

// Your function-blue constant
const Color functionBlue = Color(0xFF006FF9);

class CourseSelectionPage extends StatefulWidget {
  final String category;
  const CourseSelectionPage({super.key, required this.category});

  @override
  State<CourseSelectionPage> createState() => _CourseSelectionPageState();
}

class _CourseSelectionPageState extends State<CourseSelectionPage> {
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture =
        CourseService.instance.fetchCoursesByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Center the title, and make the back-arrow icon blue
        title: Text('${widget.category} Courses'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: functionBlue),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const Center(
              child: Text(
                "No courses found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: courses.length,
            itemBuilder: (_, index) {
              final course = courses[index];
              return SizedBox(
                height: 100,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: course.thumbnailUrl != null &&
                      course.thumbnailUrl!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      course.thumbnailUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(
                    Icons.library_books,
                    size: 32,
                    color: functionBlue,
                  ),
                  title: Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    course.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailPage(course: course),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppNavigationBar(
        selectedIndex: 1,
        isAdmin: false,
      ),
    );
  }
}
