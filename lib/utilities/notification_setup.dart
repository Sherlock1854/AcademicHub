// lib/utilities/notification_setup.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  await _requestPermission();
  await _saveFcmToken();
  await _setupForegroundNotification();
}

Future<void> _requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('🔔 Notification permission status: ${settings.authorizationStatus}');
}

Future<void> _saveFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );
  }

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).set(
      {'fcmToken': newToken},
      SetOptions(merge: true),
    );
  });
}

Future<void> _setupForegroundNotification() async {
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final android = notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
}
