// lib/course/views/course_category_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/course/services/course_service.dart';
import 'package:academichub/course/models/course.dart';
import 'package:academichub/course/views/course_selection_page.dart';
import 'package:academichub/course/views/course_detail_page.dart';
import 'package:academichub/bottom_nav.dart';

const Color functionBlue = Color(0xFF006FF9);

class CourseCategoryPage extends StatefulWidget {
  const CourseCategoryPage({Key? key}) : super(key: key);

  @override
  _CourseCategoryPageState createState() => _CourseCategoryPageState();
}

class _CourseCategoryPageState extends State<CourseCategoryPage> {
  late Future<List<String>> _categoriesFuture;
  final TextEditingController _searchController = TextEditingController();
  Future<List<Course>>? _searchFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CourseService.instance.fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    setState(() {
      if (keyword.isEmpty) {
        _searchFuture = null;
      } else {
        _searchFuture = CourseService.instance.searchCoursesByTitle(keyword);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course'),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: functionBlue),
      ),
      body: Column(
        children: [
          // ── Search Bar ───────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              cursorColor: functionBlue,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: 'Search courses…',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: functionBlue),
                  onPressed: _onSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: functionBlue, width: 2),
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────
          Expanded(
            child: _searchFuture == null
            // Show category list when not searching
                ? FutureBuilder<List<String>>(
              future: _categoriesFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading categories:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 16),
                    ),
                  );
                }
                final categories = snapshot.data;
                if (categories == null || categories.isEmpty) {
                  return const Center(
                    child: Text(
                      'No categories found.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final category = categories[index];
                    return ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: category.toLowerCase() == 'math'
                          ? const Icon(
                        Icons.calculate,
                        color: functionBlue,
                        size: 28,
                      )
                          : null,
                      title: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: functionBlue,
                        size: 24,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CourseSelectionPage(
                                    category: category),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            )

            // Show search results when searching
                : FutureBuilder<List<Course>>(
              future: _searchFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final results = snapshot.data!;
                if (results.isEmpty) {
                  return const Center(
                    child: Text(
                      'No course found, please try other keyword.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final course = results[i];
                    return ListTile(
                      leading: course.thumbnailUrl != null &&
                          course.thumbnailUrl!.isNotEmpty
                          ? ClipRRect(
                        borderRadius:
                        BorderRadius.circular(6),
                        child: Image.network(
                          course.thumbnailUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Icon(
                        Icons.library_books,
                        size: 32,
                        color: functionBlue,
                      ),
                      title: Text(course.title),
                      subtitle: Text(
                        course.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CourseDetailPage(course: course),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:
      const AppNavigationBar(selectedIndex: 1, isAdmin: false),
    );
  }
}
