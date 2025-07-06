import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';
import '../main.dart' show navigatorKey;
import 'package:flutter/foundation.dart';  // for debugPrint


/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showLocal(message);
}

final _localNotif = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  // 1) Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) Init local notifications
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  await _localNotif.initialize(
    const InitializationSettings(android: androidSettings, iOS: iosSettings),
    onDidReceiveNotificationResponse: (details) {
      final payload = details.payload;

      debugPrint('Notification tapped! payload=$payload');

      if (payload == 'friend_request') {
        navigatorKey.currentState?.pushNamed('/friend_requests');
      } else if (payload != null) {
        navigatorKey.currentState
            ?.pushNamed('/chat', arguments: payload);
      }
      // Navigate based on payload (chatId or friend_request)
    },
  );

  // 3) Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 4) Request permissions (iOS)
  await FirebaseMessaging.instance.requestPermission();

  // 5) Get & save the token
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    // e.g. save it under users/{uid}/fcmToken in Firestore
    // await FirebaseFirestore.instance.doc('users/$uid').update({'fcmToken': token});
  }

  // 6) Foreground message handler
  FirebaseMessaging.onMessage.listen(_showLocal);

  // 7) When user taps a notification
  FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    final payload = msg.data['chatId'] ?? msg.data['type'];
    debugPrint('Notification opened! payload=$payload');
    if (payload == 'friend_request') {
      navigatorKey.currentState?.pushNamed('/friend_requests');
    } else if (payload != null) {
      navigatorKey.currentState?.pushNamed('/chat', arguments: payload);
    }
  });
}

/// Helper to display a local notification
Future<void> _showLocal(RemoteMessage msg) async {
  final notification = msg.notification;
  if (notification == null) return;

  const androidDetails = AndroidNotificationDetails(
    'default_channel', 'Default',
    channelDescription: 'General notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails();
  final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  await _localNotif.show(
    msg.hashCode,
    notification.title,
    notification.body,
    details,
    payload: msg.data['chatId'] ?? msg.data['type'],
  );
}
