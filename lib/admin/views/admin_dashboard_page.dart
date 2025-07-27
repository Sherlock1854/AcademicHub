import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(child: Text('Overview metrics and charts go here')),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: 0,
        isAdmin: true,
      ),
    );
  }
}
