import 'package:flutter/material.dart';
import 'topic_list_screen.dart';
import 'feed_screen.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({super.key});
  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _idx = 0;
  static const _pages = [
    FeedScreen(),
    Center(child: Text('Courses')),
    Center(child: Text('Quizzes')),
    TopicListScreen(),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Quizzes'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
