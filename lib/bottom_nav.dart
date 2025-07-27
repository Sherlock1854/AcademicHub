// lib/widgets/app_navigation_bar.dart

import 'package:flutter/material.dart';

// User-facing pages
import 'package:academichub/dashboard/views/dashboard_page.dart';
import 'package:academichub/course/views/course_category_page.dart';
import 'package:academichub/quizzes/views/quizzes_page.dart';
import 'package:academichub/users/views/user_page.dart';

// Admin pages
import 'package:academichub/admin/views/admin_course_page.dart';
import 'package:academichub/admin/views/quiz_list_page.dart';
import 'package:academichub/admin/views/forum_management.dart';

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
    final theme = Theme.of(context);

    final navItems = isAdmin
        ? <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Courses'),
      BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Quizzes'),
      BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
    ]
        : <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Courses'),
      BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Quizzes'),
      BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
    ];

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
      const CourseCategoryPage(), // TODO: replace with ForumPage
      const UserSettingsPage(),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey[50],
      currentIndex: selectedIndex,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: Colors.grey[600],
      onTap: (i) {
        if (i == selectedIndex) return;

        // This will push the new page AND clear everything else
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => pages[i]),
              (route) => false,
        );
      },
      items: navItems,
    );
  }
}
