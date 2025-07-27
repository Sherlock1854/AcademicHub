// lib/models/notification_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String category;    // e.g. 'friend_request', 'comment', 'like'
  final String description; // optional extra text
  final String body;        // the main “body” field from Firestore
  final DateTime timestamp;
  final String fromUserId;
  final String? status;     // only for actionable ones (friend_request)
  final bool read;          // whether the user has seen this notification

  NotificationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.body,
    required this.timestamp,
    required this.fromUserId,
    this.status,
    this.read = false,
  });

  factory NotificationItem.fromMap(String id, Map<String, dynamic> data) {
    // parse timestamp (supports Timestamp, ISO string, or milliseconds)
    final rawTs = data['timestamp'];
    DateTime ts;
    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else if (rawTs is String) {
      ts = DateTime.parse(rawTs);
    } else if (rawTs is int) {
      ts = DateTime.fromMillisecondsSinceEpoch(rawTs);
    } else {
      ts = DateTime.now();
    }

    return NotificationItem(
      id:          id,
      title:       data['title']       as String? ?? '',
      category:    data['category']    as String? ?? '',
      description: data['description'] as String? ?? '',
      body:        data['body']        as String? ?? '',
      timestamp:   ts,
      fromUserId:  data['fromUserId']  as String? ?? '',
      status:      data['status']      as String?,
      read:        data['read']        as bool?   ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'title':       title,
      'category':    category,
      'description': description,
      'body':        body,
      'timestamp':   Timestamp.fromDate(timestamp),
      'fromUserId':  fromUserId,
      'read':        read,
    };
    if (status != null) m['status'] = status;
    return m;
  }
}
