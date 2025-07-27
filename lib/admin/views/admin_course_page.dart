import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';            // for manual fetch
import '../services/admin_service.dart';
import '../models/course.dart';
import 'course_form_page.dart';

class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({Key? key}) : super(key: key);

  @override
  _AdminCoursesPageState createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  @override
  void initState() {
    super.initState();

    // 1) Debug: listen to the real-time stream and print count
    AdminService.instance.coursesStream().listen(
          (courses) {
        debugPrint('🔔 Stream emitted ${courses.length} courses');
      },
      onError: (err) {
        debugPrint('⚠️ Stream error: $err');
      },
    );

    // 2) Manual one-off fetch to prove the client can read
    _manualFetch();
  }

  Future<void> _manualFetch() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('courses')
          .get();
      debugPrint('🔍 Manual fetch returned ${snap.docs.length} docs');
    } catch (e) {
      debugPrint('⚠️ Manual fetch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: AdminService.instance.coursesStream(),
      builder: (ctx, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final courses = snap.data ?? [];

        return Scaffold(
          appBar: AppBar(title: const Text('Manage Courses')),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : courses.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No courses yet.',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create Course'),
                  onPressed: _goToForm,
                ),
              ],
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) => _buildCourseTile(courses[i]),
          ),
          floatingActionButton: (!loading && courses.isNotEmpty)
              ? FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: _goToForm,
          )
              : null,
          bottomNavigationBar: const AppNavigationBar(
            selectedIndex: 1,
            isAdmin: true,
          ),
        );
      },
    );
  }

  Widget _buildCourseTile(Course c) {
    final url = c.thumbnailUrl;
    return ListTile(
      leading: (url != null && url.isNotEmpty)
          ? ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          url,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      )
          : const Icon(Icons.book, size: 56),
      title: Text(c.title),
      subtitle: Text(c.category),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (v) {
          if (v == 'edit') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourseFormPage(editCourse: c),
              ),
            );
          } else {
            _confirmDelete(c.id);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'remove', child: Text('Remove')),
        ],
      ),
    );
  }

  void _goToForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CourseFormPage()),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Course?'),
        content: const Text('This will permanently delete the course.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AdminService.instance.deleteCourse(id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Course deleted')));
      }
    }
  }
}
