// lib/widgets/friend_request_item.dart

import 'package:flutter/material.dart';
import '../../models/friend_request.dart';
import '../../services/friend_request_service.dart';

class FriendRequestItem extends StatelessWidget {
  final FriendRequest request;
  final _service = FriendRequestService();

  FriendRequestItem({required this.request, super.key});

  Future<void> _delete(BuildContext ctx) async {
    try {
      await _service.deleteRequest(request.id);
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Request deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> _confirm(BuildContext ctx) async {
    try {
      // Mark as accepted in Firestore (you can adjust logic / collection as needed)
      await _service.sendRequest(
        FriendRequest(
          id: request.id,
          name: request.name,
          time: request.time,
          imageUrl: request.imageUrl,
        ),
        received: false,
      );
      // Remove the original request
      await _service.deleteRequest(request.id);

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
                    OutlinedButton(
                      onPressed: () => _delete(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _confirm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
                      ),
                      child: const Text('Confirm'),
                    ),
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
