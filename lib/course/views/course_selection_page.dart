import 'package:flutter/material.dart';
import 'package:academichub/course/models/course.dart';
import 'package:academichub/course/services/course_service.dart';
import 'package:academichub/course/views/course_detail_page.dart';
import 'package:academichub/bottom_nav.dart';

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
    _coursesFuture = CourseService.instance.fetchCoursesByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} Courses')),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const Center(child: Text("No courses found."));
          }
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (_, index) {
              final course = courses[index];
              return ListTile(
                leading: course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    course.thumbnailUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.library_books),
                title: Text(course.title),
                subtitle: Text(course.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailPage(course: course),
                    ),
                  );
                },
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
