import 'package:flutter/material.dart';

// Import all your target pages
import 'dashboard/views/home_page.dart';
// import '../../views/screens/courses_page.dart';
// import '../../views/screens/quizzes_page.dart';
// import '../../views/screens/forum_page.dart';
import 'accounts/views/accounts_page.dart';

class AppNavigationBar extends StatelessWidget {
  final int selectedIndex; // The index of the currently active page/tab

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
  });

  // This function now contains the navigation logic
  void _onItemTapped(BuildContext context, int index) {
    // If the tapped index is already the current index, do nothing
    if (index == selectedIndex) {
      return;
    }

    Widget targetPage;
    switch (index) {
      case 0: // Home
        targetPage = const HomePageScreen();
        break;
      case 1: // Courses (Currently redirects to HomePageScreen)
        targetPage = const HomePageScreen(); // Replace with const CoursesPage() when ready
        debugPrint('Courses Page is not yet implemented. Redirecting to Home.');
        break;
      case 2: // Quizzes (Currently redirects to HomePageScreen)
        targetPage = const HomePageScreen(); // Replace with const QuizzesPage() when ready
        debugPrint('Quizzes Page is not yet implemented. Redirecting to Home.');
        break;
      case 3: // Forum (Currently redirects to HomePageScreen)
        targetPage = const HomePageScreen(); // Replace with const ForumPage() when ready
        debugPrint('Forum Page is not yet implemented. Redirecting to Home.');
        break;
      case 4: // Account
        targetPage = const AccountSettingsScreen(); // Use AccountPage as defined
        break;
      default:
      // Fallback for any unhandled index, prevents error
        debugPrint('Tapped unhandled index: $index. Redirecting to Home.');
        targetPage = const HomePageScreen();
        break;
    }

    // Perform pushReplacement to the selected page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Ensures all labels are shown
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue, // Using direct color
      unselectedItemColor: Colors.grey[600], // Using direct color
      // Call the internal _onItemTapped method
      onTap: (index) => _onItemTapped(context, index),
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
          icon: Icon(Icons.lightbulb_outline), // Icon for Quizzes
          label: 'Quizzes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.forum),
          label: 'Forum',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), // Icon for Account
          label: 'Account',
        ),
      ],
    );
  }
}