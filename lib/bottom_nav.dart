import 'package:flutter/material.dart';

import 'dashboard/views/dashboard_page.dart';
import 'accounts/views/accounts_page.dart';
import 'course/views/course_page.dart';
import 'quizzes/views/quizzes_page.dart';
// import 'forum/views/forum_page.dart';

class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
  });

  void _navigateTo(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget targetPage;

    switch (index) {
      case 0:
        targetPage = const DashboardPage();
        break;
      case 1:
        targetPage = const CoursesPageScreen();
        break;
      case 2:
        targetPage = const QuizzesPageScreen();
        break;
      case 3:
        targetPage = const DashboardPage(); // Replace with ForumPage()
        break;
      case 4:
        targetPage = const AccountSettingsScreen();
        break;
      default:
        targetPage = const DashboardPage();
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
      onTap: (index) => _navigateTo(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          label: 'Quizzes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.forum),
          label: 'Forum',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Account',
        ),
      ],
    );
  }
}
