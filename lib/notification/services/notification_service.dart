// lib/notifications/services/notification_service.dart

import 'dart:async';
import '../models/notification_item.dart';

class NotificationService {
  final List<NotificationItem> _storage = [
    NotificationItem(
      id: '1',
      title: 'Tech Updates',
      category: 'Weekly Newsletter',
      description: 'Here are this week’s top tech stories…',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isStarred: true,
    ),
    NotificationItem(
      id: '2',
      title: 'Your Bank',
      category: 'Security Alert',
      description: 'Suspicious activity detected on your account.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isStarred: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Account Services',
      category: 'Password Changed',
      description: 'Your password was successfully updated.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      isStarred: false,
    ),
  ];

  final _controller = StreamController<List<NotificationItem>>.broadcast();

  NotificationService() {
    // seed initial data
    _controller.add(List.from(_storage));
  }

  Stream<List<NotificationItem>> get notificationsStream => _controller.stream;

  Future<void> toggleStar(String id) async {
    final idx = _storage.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _storage[idx].isStarred = !_storage[idx].isStarred;
      _controller.add(List.from(_storage));
    }
  }

  Future<void> markRead(String id) async {
    // e.g. remove or update item
    _storage.removeWhere((n) => n.id == id);
    _controller.add(List.from(_storage));
  }

  void dispose() {
    _controller.close();
  }
}
