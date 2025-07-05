import 'package:flutter/material.dart';

void main() {
  runApp(const ForumApp());
}

class ForumApp extends StatelessWidget {
  const ForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Forum UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Data models for a forum topic
class ForumTopic {
  final IconData icon;
  final String title;

  ForumTopic({required this.icon, required this.title});
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 3; // Set 'Forum' as the default selected tab

  // Placeholder pages for other tabs
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Home Page')),
    Center(child: Text('Courses Page')),
    Center(child: Text('Quizzes Page')),
    ForumPage(), // Our main forum page
    Center(child: Text('Profile Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Collaborative forum',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Quizzes'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ForumTopic> topics = [
      ForumTopic(icon: Icons.sync, title: 'Internet of Things'),
      ForumTopic(icon: Icons.calculate_outlined, title: 'Python'),
      ForumTopic(icon: Icons.biotech_outlined, title: 'Machine Learning'),
      ForumTopic(icon: Icons.grid_on_outlined, title: 'Web Development'),
      ForumTopic(icon: Icons.lock_outline, title: 'Cybersecurity'),
      ForumTopic(icon: Icons.psychology_alt_outlined, title: 'Artificial Intelligence'),
      ForumTopic(icon: Icons.share_outlined, title: 'Blockchain'),
      ForumTopic(icon: Icons.cloud_queue_outlined, title: 'Cloud Computing'),
      ForumTopic(icon: Icons.info_outline, title: 'Data Science'),
      ForumTopic(icon: Icons.vrpano_outlined, title: 'Virtual Reality'),
    ];

    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return ListTile(
          leading: Icon(topic.icon, color: Colors.blue),
          title: Text(topic.title),
          onTap: () {
            // Handle tapping on a forum topic
          },
        );
      },
    );
  }
}