import 'package:flutter/material.dart';
//----------
import 'package:cloud_functions/cloud_functions.dart';
//-------------
// Assuming bottom_nav.dart contains your AppNavigationBar
import '../../bottom_nav.dart'; // Make sure this path is correct for AppNavigationBar
import '../../accounts/views/accounts_page.dart'; // Account page is still active
import 'package:academichub/notification/views/notifications_screen.dart';
import 'package:academichub/friend/views/friends_screen.dart';

// Import other pages if they become active
// import '../../courses/views/courses_page.dart'; // Uncomment when ready
// import '../../quizzes/views/quizzes_page.dart'; // Uncomment when ready
// import '../../forum/views/forum_page.dart';     // Uncomment when ready


class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  //--------
  /// Quick helper to call your Cloud Function
  Future<void> _sendTestNotification(BuildContext context) async {
    final fn = FirebaseFunctions.instance.httpsCallable('sendPushNotification');
    try {
      final res = await fn.call(<String, dynamic>{
        'targetUserId': '0BZ5wXbwaDXWNRRFjSeEyUiuz4v2',  // replace with your UID
        'title': 'Test Notification',
        'body': 'Hello from FAB!'
      });
      final ok = res.data['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? '✅ Function succeeded'
              : '⚠️ Function returned failure'),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }
  //-----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => NotificationsScreen(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const FriendsScreen(),
              ));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Your Courses",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  "Home Page Content (Your Enrolled Courses List Here)",
                  style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 0), // Index 0 for Home
      //------
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendTestNotification(context),
        tooltip: 'Send Test Notification',
        child: const Icon(Icons.send),
      ),
      //-------
    );
  }
}