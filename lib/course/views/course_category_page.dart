import 'package:flutter/material.dart';
import 'package:academichub/course/services/course_service.dart';
import 'course_selection_page.dart';
import 'package:academichub/bottom_nav.dart';

class CourseCategoryPage extends StatelessWidget {
  const CourseCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Course Category")),
      body: FutureBuilder<List<String>>(
        future: CourseService.instance.fetchCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseSelectionPage(category: category),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppNavigationBar(
        selectedIndex: 1, // 0 = Home, 1 = Courses, 2 = Quizzes, ...
        isAdmin: false,   // This is the user view
      ),
    );
  }
}
