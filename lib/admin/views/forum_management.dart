import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';

class AdminForumManagementPage extends StatelessWidget {
  const AdminForumManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Forum')),
      body: Center(child: Text('List of forum posts to moderate goes here')),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: 2,
        isAdmin: true,
      ),
    );
  }
}
