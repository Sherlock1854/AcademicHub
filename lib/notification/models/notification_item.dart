// lib/notifications/models/notification_item.dart

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

  /// For Firestore / JSON decoding
  factory NotificationItem.fromMap(String id, Map<String, dynamic> data) {
    return NotificationItem(
      id: id,
      title: data['title'] as String,
      category: data['category'] as String,
      description: data['description'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
      isStarred: data['isStarred'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'category': category,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'isStarred': isStarred,
  };
}
