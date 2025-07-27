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
    final displayName = isSent ? request.toName : request.fromName;
    final displayImage = request.imageUrl;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/fail.png',
                      image: displayImage,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      imageErrorBuilder:
                          (_, __, ___) => Image.asset(
                            'assets/images/fail.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeLabel,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child:
                  isSent
                      ? OutlinedButton(
                        onPressed:
                            request.status == 'pending'
                                ? () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  await service.cancelRequest(request.id);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Cancelled request to $displayName',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed:
                                request.status == 'pending'
                                    ? () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      await service.declineRequest(request.id);
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Declined request from $displayName',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
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
                            onPressed:
                                request.status == 'pending'
                                    ? () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      await service.acceptRequest(request);
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Accepted request from $displayName',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
