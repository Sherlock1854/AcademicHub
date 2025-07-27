// lib/course/views/course_category_page.dart

import 'package:flutter/material.dart';
import 'package:academichub/course/services/course_service.dart';
import 'course_selection_page.dart';
import 'package:academichub/bottom_nav.dart';

// Your function-blue constant
const Color functionBlue = Color(0xFF006FF9);

class CourseCategoryPage extends StatefulWidget {
  const CourseCategoryPage({super.key});

  @override
  _CourseCategoryPageState createState() => _CourseCategoryPageState();
}

class _CourseCategoryPageState extends State<CourseCategoryPage> {
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = CourseService.instance.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading categories:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text(
                "No categories found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, index) {
              final category = data[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: category.toLowerCase() == 'math'
                    ? const Icon(
                  Icons.calculate,
                  color: functionBlue,
                  size: 28, // larger icon
                )
                    : null,
                title: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,  // larger text
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: functionBlue,
                  size: 24, // larger arrow
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CourseSelectionPage(category: category),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppNavigationBar(
        selectedIndex: 1, // Courses tab
        isAdmin: false,
      ),
    );
  }
}
