// lib/friend/widgets/friend_request_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/friend_request.dart';
import '../../services/friend_request_service.dart';

class FriendRequestItem extends StatelessWidget {
  final FriendRequest request;
  final bool isSent;

  const FriendRequestItem({
    Key? key,
    required this.request,
    this.isSent = false,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = FriendRequestService();

    // Optional: format your ISO timestamp into a short date
    DateTime? dt = DateTime.tryParse(request.time);
    final timeLabel = dt != null
        ? DateFormat('MMM d').format(dt)
        : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(request.imageUrl),
      ),
      title: Text(
        request.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: timeLabel.isNotEmpty
          ? Text(
        timeLabel,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      )
          : null,
      trailing: isSent
      // ───────────────────────────── Sent requests ─────────────────────────────
          ? OutlinedButton(
        onPressed: () async {
          await service.cancelRequest(request.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cancelled request to ${request.name}')),
          );
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(80, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Cancel'),
      )

      // ─────────────────────────── Received requests ──────────────────────────
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () async {
              await service.declineRequest(request.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Declined request from ${request.name}')),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Decline'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              await service.acceptRequest(request);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Accepted request from ${request.name}')),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
