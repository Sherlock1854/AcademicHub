import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:academichub/bottom_nav.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import 'course_detail_page.dart';

const Color functionBlue = Color(0xFF006FF9);

class CourseSearchPage extends StatefulWidget {
  const CourseSearchPage({Key? key}) : super(key: key);

  @override
  State<CourseSearchPage> createState() => _CourseSearchPageState();
}

class _CourseSearchPageState extends State<CourseSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Course>>? _searchFuture;

  void _onSearch(String keyword) {
    setState(() {
      _searchFuture =
          CourseService.instance.searchCoursesByTitle(keyword.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: functionBlue),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search courses...',
            border: InputBorder.none,
          ),
          onSubmitted: _onSearch,
        ),
      ),
      body: _searchFuture == null
          ? const Center(
        child: Text('Enter a keyword to search courses.'),
      )
          : FutureBuilder<List<Course>>(
        future: _searchFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Error: ${snap.error}'));
          }
          final results = snap.data!;
          if (results.isEmpty) {
            return const Center(
              child: Text(
                'No course found, please try other keyword.',
              ),
            );
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) {
              final c = results[i];
              return ListTile(
                leading: c.thumbnailUrl != null &&
                    c.thumbnailUrl!.isNotEmpty
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(6),
                  child: Image.network(
                    c.thumbnailUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.library_books,
                  color: functionBlue,
                ),
                title: Text(c.title),
                subtitle: Text(
                  c.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CourseDetailPage(course: c),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar:
      const AppNavigationBar(selectedIndex: 1, isAdmin: false),
    );
  }
}
