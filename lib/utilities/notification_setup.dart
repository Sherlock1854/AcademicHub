// lib/utilities/notification_setup.dart

import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart'; // for navigatorKey & notificationTapBackground

/// Tracks which chat is currently on screen (to suppress duplicates)
String? activeChatFriendId;

/// Top-level background handler (for terminated/background taps)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  WidgetsFlutterBinding.ensureInitialized();
  final friendId = response.payload;
  if (friendId != null) {
    navigatorKey.currentState?.pushNamed('/chat', arguments: friendId);
  }
}

/// Our single F.L.N. plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Call this from `main()` (before runApp)
Future<void> initNotifications() async {
  // 1️⃣ Init local notifications
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidInit),
    onDidReceiveNotificationResponse: (resp) {
      final fid = resp.payload;
      if (fid != null) {
        navigatorKey.currentState?.pushNamed('/chat', arguments: fid);
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // 2️⃣ Create (or reuse) an Android channel
  const channel = AndroidNotificationChannel(
    'chat_channel',
    'Chat Messages',
    description: 'Incoming chat messages',
    importance: Importance.max,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 3️⃣ Request permissions (iOS; no-op on Android)
  await FirebaseMessaging.instance.requestPermission();

  // 4️⃣ Grab & persist the FCM token
  final fcm = FirebaseMessaging.instance;
  final token = await fcm.getToken();
  if (token != null) _saveFcmToken(token);
  fcm.onTokenRefresh.listen(_saveFcmToken);

  // 5️⃣ Foreground messages → show a local popup for *any* type
  FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
    final data  = msg.data;
    final type  = data['type'] as String? ?? 'unknown';
    final title = msg.notification?.title ?? 'New notification';
    final body  = msg.notification?.body  ?? data['body'] ?? '';

    // Persist into your “Notifications” collection
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid != null) {
      final notifRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(myUid)
          .collection('notifications')
          .doc();
      await notifRef.set({
        'id':        notifRef.id,
        'fromUid':   data['fromUid'] ?? data['friendId'] ?? '',
        'title':     title,
        'body':      body,
        'timestamp': FieldValue.serverTimestamp(),
        'read':      false,
        'type':      type,
      });
    }

    // Decide payload & suppression
    String? payload;
    bool canShow = true;
    if (type == 'chat_message') {
      payload = data['friendId'] as String?;
      if (payload == activeChatFriendId) {
        canShow = false; // already in that chat
      }
    }

    if (canShow) {
      flutterLocalNotificationsPlugin.show(
        msg.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: payload,
      );
    }
  });

  // 6️⃣ When user taps a notification in background
  FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    final fid = msg.data['friendId'] as String?;
    if (fid != null) {
      navigatorKey.currentState?.pushNamed('/chat', arguments: fid);
    }
  });

  // 7️⃣ When app was killed and opened via notification
  final initMsg = await FirebaseMessaging.instance.getInitialMessage();
  if (initMsg != null) {
    final fid = initMsg.data['friendId'] as String?;
    if (fid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushNamed('/chat', arguments: fid);
      });
    }
  }
}

/// Save your FCM token under Users/{uid}.fcmToken
Future<void> _saveFcmToken(String token) async {
  final me = FirebaseAuth.instance.currentUser;
  if (me == null) return;
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(me.uid)
      .update({'fcmToken': token});
}
