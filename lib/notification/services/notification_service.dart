import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/notification_item.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Reference to the current user's notifications collection
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('Users').doc(_uid).collection('notifications');

  /// Stream all notifications for the current user, ordered by newest first
  Stream<List<NotificationItem>> get notificationsStream {
    return _col.orderBy('timestamp', descending: true).snapshots().map(
          (snap) => snap.docs
          .map((doc) => NotificationItem.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  /// Send a new notification:
  /// - Save to Firestore
  /// - Trigger FCM push notification via Firebase Cloud Function
  Future<void> sendNotification({
    required String toUserId,
    required NotificationItem item,
  }) async {
    final docRef = _db
        .collection('Users')
        .doc(toUserId)
        .collection('notifications')
        .doc(item.id);

    // Save to Firestore
    await docRef.set(item.toMap());

    // Send push notification via Cloud Function (optional fallback if token not stored)
    try {
      final callable = _functions.httpsCallable('sendPushNotification');
      await callable.call({
        'targetUserId': toUserId,
        'title': item.title,
        'body': item.description,
      });
    } catch (e) {
      print('⚠️ FCM push notification failed: $e');
    }
  }

  /// Mark a notification as read (delete it)
  Future<void> markRead(String id) {
    return _col.doc(id).delete();
  }

  /// Update notification status (used for friend request accept/decline)
  Future<void> updateStatus(String id, String status) {
    return _col.doc(id).update({'status': status});
  }
}
