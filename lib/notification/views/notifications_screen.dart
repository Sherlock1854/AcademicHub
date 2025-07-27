// lib/notification/views/notifications_screen.dart

import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/notification_service.dart';
import 'widget/notification_item_widget.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({Key? key}) : super(key: key);
  final NotificationService _service = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,            // overall background
      appBar: AppBar(
        backgroundColor: Colors.grey[50],       // light grey bar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: StreamBuilder<List<NotificationItem>>(
        stream: _service.notificationsStream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => NotificationItemWidget(
              item: items[i],
              service: _service,
            ),
          );
        },
      ),
    );
  }
}
