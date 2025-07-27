import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'auth/auth_gate.dart';
import 'firebase_options.dart';
import 'utilities/notification_setup.dart';

/// So we can navigate on notification taps, even from background.
final navigatorKey = GlobalKey<NavigatorState>();

/// This must be a top-level entry-point so the background isolate can invoke it.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null) {
    // Ensure Flutter bindings are initialized in background isolate:
    WidgetsFlutterBinding.ensureInitialized();
    navigatorKey.currentState?.pushNamed('/chat', arguments: payload);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Sets up both FCM and local notifications (including wiring our background handler)
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
      theme: ThemeData(
        useMaterial3: true,
        // ← add the textSelectionTheme here
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blue,           // the blinking caret
          selectionHandleColor: Colors.blue,  // the draggable “teardrop”
          selectionColor: Color(0x663399FF),  // highlight color when you drag‐select text
        ),
        // ... any other theme settings ...
      ),
      home: const AuthGate(),
      // You’ll need a '/chat' route in your MaterialApp.routes if you want
      // navigatorKey.currentState?.pushNamed('/chat', ...) to work.
    );
  }
}
