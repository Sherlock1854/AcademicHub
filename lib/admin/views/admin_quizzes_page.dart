import 'package:flutter/material.dart';
import 'package:academichub/bottom_nav.dart';

class AdminQuizzesPage extends StatelessWidget {
  const AdminQuizzesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Quizzes')),
      body: Center(child: Text('Quiz list with add/edit/delete goes here')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Navigator.push to your QuizFormPage
        },
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: 0,
        isAdmin: true,
      ),
    );
  }
}
