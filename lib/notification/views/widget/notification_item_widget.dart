// lib/notification/widgets/notification_item_widget.dart

import 'package:flutter/material.dart';
import '../../models/notification_item.dart';
import '../../services/notification_service.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationItem item;
  final NotificationService service;

  const NotificationItemWidget({
    required this.item,
    required this.service,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = item.read; // never null

    return Container(
      color: Colors.white,
      child: ListTile(
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isRead ? Colors.grey : Colors.black,
              ),
            ),
            Text(
              _formatTime(item.timestamp),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.category,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              item.body,
              style: TextStyle(
                color: isRead ? Colors.grey : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: null,  // remove the chevron
        onTap: () => service.markRead(item.id),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays  >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
