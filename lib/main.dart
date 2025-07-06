import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_gate.dart';
import 'chat/views/chat_screen.dart';
import 'friend/views/friends_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'AcademyHub',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
