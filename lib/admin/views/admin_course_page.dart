// lib/admin/views/admin_course_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/admin_service.dart';
import '../models/course.dart';
import 'course_form_page.dart';

const Color functionBlue = Color(0xFF006FF9);

class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({Key? key}) : super(key: key);

  @override
  _AdminCoursesPageState createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  @override
  void initState() {
    super.initState();
    AdminService.instance.coursesStream().listen(
          (courses) => debugPrint('🔔 ${courses.length} courses'),
      onError: (err) => debugPrint('⚠️ $err'),
    );
    _manualFetch();
  }

  Future<void> _manualFetch() async {
    try {
      final snap =
      await FirebaseFirestore.instance.collection('courses').get();
      debugPrint('🔍 ${snap.docs.length} docs fetched manually');
    } catch (e) {
      debugPrint('⚠️ $e');
    }
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
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: functionBlue,
              side: const BorderSide(color: functionBlue),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AdminService.instance.deleteCourse(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted')),
        );
      }
    }
  }

  Widget _buildCourseTile(Course c) {
    final url = c.thumbnailUrl;
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
          : const Icon(Icons.book, size: 56, color: functionBlue),
      title: Text(c.title, style: const TextStyle(fontSize: 18)),
      subtitle: Text(c.category),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: functionBlue),
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
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(
            value: 'remove',
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: AdminService.instance.coursesStream(),
      builder: (ctx, snap) {
        final loading =
            snap.connectionState == ConnectionState.waiting;
        final courses = snap.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Manage Courses',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: functionBlue),
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : courses.isEmpty
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No courses yet.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _goToForm,
                  icon: const Icon(Icons.add,
                      color: functionBlue),
                  label: const Text(
                    'Create Course',
                    style: TextStyle(color: functionBlue),
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                        color: functionBlue),
                  ),
                ),
              ],
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            separatorBuilder: (_, __) =>
            const Divider(),
            itemBuilder: (_, i) =>
                _buildCourseTile(courses[i]),
          ),
          floatingActionButton: (!loading && courses.isNotEmpty)
              ? FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: functionBlue,
            onPressed: _goToForm,
            child: const Icon(Icons.add),
          )
              : null,
          bottomNavigationBar: const AppNavigationBar(
            selectedIndex: 0,
            isAdmin: true,
          ),
        );
      },
    );
  }
}
