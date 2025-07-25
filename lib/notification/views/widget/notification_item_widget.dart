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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(_formatTime(item.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.category, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(height: 4),
          Text(item.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          if (item.status != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    service.updateStatus(item.id, 'accepted');
                    service.markRead(item.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    service.updateStatus(item.id, 'declined');
                    service.markRead(item.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Decline', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ]
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Auto mark read on tap for now
        service.markRead(item.id);
      },
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
