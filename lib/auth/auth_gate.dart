import 'package:academichub/auth/views/login.dart';
import 'package:academichub/dashboard/views/dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            // user id logged in
            if(snapshot.hasData){
              return const DashboardPage();
            }else{
              //To login page
              return const LoginPage();
            }
          }
      ),
    );
  }
}
