import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String category; // e.g., 'friend_request', 'comment', 'like'
  final String description;
  final DateTime timestamp;
  final String fromUserId;
  final String? status; // Optional: Only for actionable notifications like 'friend_request'

  NotificationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.timestamp,
    required this.fromUserId,
    this.status,
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
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      timestamp: dt,
      fromUserId: data['fromUserId'] ?? '',
      status: data['status'], // may be null
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'title': title,
      'category': category,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'fromUserId': fromUserId,
    };
    if (status != null) map['status'] = status;
    return map;
  }
}
