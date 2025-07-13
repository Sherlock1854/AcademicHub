// lib/notifications/models/notification_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String category;
  final String description;
  final DateTime timestamp;
  bool isStarred;

  NotificationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.timestamp,
    this.isStarred = false,
  });

  factory NotificationItem.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['timestamp'];
    DateTime dt;
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else {
      dt = DateTime.parse(ts as String);
    }
    return NotificationItem(
      id: id,
      title: data['title'] as String,
      category: data['category'] as String,
      description: data['description'] as String,
      timestamp: dt,
      isStarred: data['isStarred'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'category': category,
    'description': description,
    'timestamp': Timestamp.fromDate(timestamp),
    'isStarred': isStarred,
  };
}
