// lib/widgets/app_navigation_bar.dart

import 'package:flutter/material.dart';

// User-facing pages
import 'package:academichub/dashboard/views/dashboard_page.dart';
import 'package:academichub/course/views/course_category_page.dart';
import 'package:academichub/quizzes/views/quizzes_page.dart';
import 'package:academichub/users/views/user_page.dart';

// Admin pages
import 'package:academichub/admin/views/admin_dashboard_page.dart';
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

  void _navigateTo(BuildContext context, int index) {
    if (index == selectedIndex) return;

    late final Widget targetPage;

    if (!isAdmin) {
      // ─── Regular user ───
      switch (index) {
        case 0:
          targetPage = const DashboardPage();
          break;
        case 1:
          targetPage = const CourseCategoryPage();
          break;
        case 2:
          targetPage = const QuizzesPageScreen();
          break;
        case 3:
        // TODO: replace with your real ForumPage
          targetPage = const CourseCategoryPage();
          break;
        case 4:
          targetPage = const UserSettingsPage();
          break;
        default:
          targetPage = const DashboardPage();
      }
    } else {
      // ─── Admin ───
      switch (index) {
        case 0:
          targetPage = const AdminDashboardPage();
          break;
        case 1:
          targetPage = const AdminCoursesPage();
          break;
        case 2:
          targetPage = const QuizListPage();
          break;
        case 3:
          targetPage = const AdminForumManagementPage();
          break;
        case 4:
          targetPage = const UserSettingsPage();
          break;
        default:
          targetPage = const AdminDashboardPage();
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[600],
      onTap: (i) => _navigateTo(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home),               label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.library_books),     label: 'Courses'),
        BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Quizzes'),
        BottomNavigationBarItem(icon: Icon(Icons.forum),              label: 'Forum'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline),    label: 'Account'),
      ],
    );
  }
}
