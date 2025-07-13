// lib/notifications/services/notification_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_item.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('Users').doc(_uid).collection('notifications');

  /// Stream all notifications, newest first
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

  /// Toggle the `isStarred` flag on a notification
  Future<void> toggleStar(String id) {
    final doc = _col.doc(id);
    return doc.update({
      'isStarred': FieldValue.serverTimestamp(), // or invert existing flag if you read it client-side
    });
  }

  /// Mark as read by deleting the document
  Future<void> markRead(String id) {
    return _col.doc(id).delete();
  }
}
