// lib/widgets/app_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:academichub/dashboard/views/dashboard_page.dart';
import 'package:academichub/course/views/course_category_page.dart';
import 'package:academichub/quizzes/views/quizzes_page.dart';
import 'package:academichub/users/views/user_page.dart';
import 'package:academichub/admin/views/admin_course_page.dart';
import 'package:academichub/admin/views/quiz_list_page.dart';
import 'package:academichub/admin/views/forum_management.dart';

const Color functionBlue = Color(0xFF006FF9);

class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final bool isAdmin;

  const AppNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define your pages per role
    final pages = isAdmin
        ? <Widget>[
      const AdminCoursesPage(),
      const QuizListPage(),
      const AdminForumManagementPage(),
      const UserSettingsPage(),
    ]
        : <Widget>[
      const DashboardPage(),
      const CourseCategoryPage(),
      const QuizzesPageScreen(),
      const CourseCategoryPage(), // Forum placeholder
      const UserSettingsPage(),
    ];

    // Define your nav items per role
    final items = isAdmin
        ? [
      const BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Courses'),
      const BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Quizzes'),
      const BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
    ]
        : [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Courses'),
      const BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Quizzes'),
      const BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey[50],
      currentIndex: selectedIndex,
      selectedItemColor: functionBlue,    // pressed/selected icon & label are blue
      unselectedItemColor: Colors.grey[600],
      onTap: (i) {
        if (i == selectedIndex) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => pages[i]),
              (route) => false,
        );
      },
      items: items,
    );
  }
}
