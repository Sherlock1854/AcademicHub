// lib/widgets/friend_request_item.dart

import 'package:flutter/material.dart';
import '../../models/friend_request.dart';
import '../../services/friend_request_service.dart';

class FriendRequestItem extends StatelessWidget {
  final FriendRequest request;
  final bool isSent;
  final FriendRequestService _service = FriendRequestService();

  FriendRequestItem({
    Key? key,
    required this.request,
    this.isSent = false,
  }) : super(key: key);

  Future<void> _cancel(BuildContext ctx) async {
    try {
      await _service.cancelRequest(request.id);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Request cancelled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Cancel failed: $e')),
      );
    }
  }

  Future<void> _decline(BuildContext ctx) async {
    try {
      await _service.declineRequest(request.id);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Request deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> _accept(BuildContext ctx) async {
    try {
      await _service.acceptRequest(request);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Friend request accepted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Confirm failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(request.imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      request.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      request.time,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isSent) ...[
                      OutlinedButton(
                        onPressed: () => _cancel(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ] else ...[
                      OutlinedButton(
                        onPressed: () => _decline(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _accept(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
