import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth_gate.dart';
import 'firebase_options.dart';
import 'utilities/notification_setup.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AcademicHub',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
