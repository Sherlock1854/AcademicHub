// lib/notifications/views/notifications_screen.dart

import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import 'notification_item_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: StreamBuilder<List<NotificationItem>>(
        stream: _service.notificationsStream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(
              child: Text('No notifications',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: items.length,
            itemBuilder: (ctx, i) => NotificationItemWidget(
              item: items[i],
              service: _service,
            ),
          );
        },
      ),
    );
  }
}
