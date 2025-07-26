import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import your active-chat tracker
import 'active_chat.dart';
// import your top-level handler from main.dart
import '../main.dart'; // so we can call notificationTapBackground and navigatorKey

/// The single instance of the local notifications plugin.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Call this from main() before runApp.
Future<void> initNotifications() async {
  // 1) Initialize flutter_local_notifications
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidInit),
    onDidReceiveNotificationResponse: (NotificationResponse resp) {
      final payload = resp.payload;
      if (payload != null) {
        navigatorKey.currentState?.pushNamed('/chat', arguments: payload);
      }
    },
    // ← use your top-level background handler here:
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // 2) Request FCM permissions (iOS)
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  // 3) Configure Android channel (for API ≥26)
  const channel = AndroidNotificationChannel(
    'chat_channel',       // id
    'Chat Messages',      // name
    description: 'Incoming chat messages',
    importance: Importance.max,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 4) Handle when the app is in the foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
    final data = msg.data;
    final fromFriendId = data['friendId'] as String?;
    final notifText = msg.notification?.body ?? data['text'] ?? '';
    final notifTitle = msg.notification?.title ?? 'New message';

    // 1️⃣ Persist into Firestore for your "Notifications" page
    if (fromFriendId != null) {
      final myUid = FirebaseAuth.instance.currentUser!.uid;
      final notifRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(myUid)
          .collection('notifications')
          .doc();
      await notifRef.set({
        'id':        notifRef.id,
        'fromUid':   fromFriendId,
        'title':     notifTitle,
        'body':      notifText,
        'timestamp': FieldValue.serverTimestamp(),
        'read':      false,
        'type':      'chat_message',
      });
    }

    // 2️⃣ Only pop-up if not already in that chat
    if (fromFriendId != activeChatFriendId) {
      final n = msg.notification;
      if (n != null) {
        flutterLocalNotificationsPlugin.show(
          n.hashCode,
          n.title,
          n.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: fromFriendId,
        );
      }
    }
  });

  // 5) Handle taps when app is backgrounded or terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
    final fromFriendId = msg.data['friendId'];
    if (fromFriendId != null) {
      navigatorKey.currentState?.pushNamed('/chat', arguments: fromFriendId);
    }
  });

  // 6) If the app was completely killed and opened via a notification
  final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMsg != null) {
    final fromFriendId = initialMsg.data['friendId'];
    if (fromFriendId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushNamed('/chat', arguments: fromFriendId);
      });
    }
  }
}
