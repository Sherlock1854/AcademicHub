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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = FriendRequestService();
    final timeLabel = DateFormat('MMM d').format(request.created);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/fail.png',
            image: request.imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            imageErrorBuilder: (_, __, ___) => Image.asset(
              'assets/images/fail.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      title: Text(
        request.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        timeLabel,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: isSent
          ? OutlinedButton(
        onPressed: request.status == 'pending'
            ? () async {
          await service.cancelRequest(request.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cancelled request to ${request.name}')),
          );
        }
            : null,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(80, 36),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.blue),
        ),
      )
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: request.status == 'pending'
                ? () async {
              await service.declineRequest(request.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Declined request from ${request.name}')),
              );
            }
                : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(80, 36),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Decline',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: request.status == 'pending'
                ? () async {
              await service.acceptRequest(request);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Accepted request from ${request.name}')),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 36),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Accept',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
