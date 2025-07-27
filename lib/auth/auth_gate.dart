import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../course/views/course_category_page.dart';
import '../dashboard/views/dashboard_page.dart';
import '../admin/views/admin_course_page.dart';
import 'views/login.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!authSnap.hasData) {
          return const LoginPage();
        }
        final uid = authSnap.data!.uid;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(uid).get(),
          builder: (ctx2, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (roleSnap.hasError || !roleSnap.hasData) {
              return const CourseCategoryPage();
            }
            final data = roleSnap.data!.data() as Map<String, dynamic>?;
            final role = data?['role'] as String? ?? 'user';
            if (role == 'admin') {
              return const AdminCoursesPage();
            } else {
              return const DashboardPage();
            }
          },
        );
      },
    );
  }
}
