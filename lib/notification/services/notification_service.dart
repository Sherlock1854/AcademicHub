import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_item.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Returns the reference to the current user's notifications subcollection
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('Users').doc(_uid).collection('notifications');

  /// Stream all notifications for the current user, newest first
  Stream<List<NotificationItem>> get notificationsStream {
    return _col
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => NotificationItem.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  /// Add a new notification for a specific user (e.g. when someone sends a friend request)
  Future<void> sendNotification({
    required String toUserId,
    required NotificationItem item,
  }) {
    final ref = _db
        .collection('Users')
        .doc(toUserId)
        .collection('notifications')
        .doc(item.id);

    return ref.set(item.toMap());
  }

  /// Mark a notification as read by deleting it
  Future<void> markRead(String id) {
    return _col.doc(id).delete();
  }

  /// Update status of actionable notification (e.g., friend request accepted/declined)
  Future<void> updateStatus(String id, String status) {
    return _col.doc(id).update({'status': status});
  }
}
