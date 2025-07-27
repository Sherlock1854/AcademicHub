// lib/auth/views/auth_gate.dart

import 'package:academichub/admin/views/admin_dashboard_page.dart';
import 'package:academichub/course/views/course_category_page.dart';
import 'package:academichub/auth/views/login.dart';
import 'package:academichub/dashboard/views/dashboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:academichub/admin/views/admin_course_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, authSnap) {
          // still checking auth state
          if (authSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // not logged in → show login
          if (!authSnap.hasData) {
            return const LoginPage();
          }

          // logged in → fetch role
          final uid = authSnap.data!.uid;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Users')
                .doc(uid)
                .get(),
            builder: (ctx2, roleSnap) {
              if (roleSnap.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (roleSnap.hasError || !roleSnap.hasData) {
                // fallback to user view on error
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
      ),
    );
  }
}
