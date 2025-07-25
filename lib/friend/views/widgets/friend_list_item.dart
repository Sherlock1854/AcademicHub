// lib/screens/widgets/friend_list_item.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/friend_service.dart';
import '../../models/friend.dart';
import '../../../chat/views/chat_screen.dart';
import '../../../chat/services/chat_service.dart';  // for deletion

class FriendListItem extends StatelessWidget {
  final Friend friend;

  const FriendListItem({Key? key, required this.friend}) : super(key: key);

  String _formatTimestamp(DateTime? ts) {
    if (ts == null) return '';
    final now = DateTime.now();
    final diff = now.difference(ts).inDays;
    if (diff == 0) return DateFormat('h:mm a').format(ts);
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return DateFormat('MMM d').format(ts);
  }

  @override
  Widget build(BuildContext context) {
    final svc = FriendService();
    final chatSvc = ChatService();

    final raw = friend.lastIsImage ? '[picture]' : friend.lastText;
    final subtitle = friend.lastIsSender ? 'You: $raw' : raw;
    final time = _formatTimestamp(friend.lastTimestamp);

    // Avatar: try network URL → fallback asset → fallback icon
    final avatar = friend.avatarUrl.isNotEmpty
        ? CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          friend.avatarUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/fail.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
      ),
    )
        : const CircleAvatar(
      radius: 24,
      child: Icon(Icons.person),
    );

    return GestureDetector(
      onLongPress: () => _showOptions(context, svc, chatSvc),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: avatar,
        title: Text(
          friend.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (time.isNotEmpty)
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            const SizedBox(height: 4),
            if (friend.hasUnreadMessages)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            if (friend.pinned)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.push_pin, size: 16, color: Colors.grey),
              ),
          ],
        ),
        onTap: () async {
          await svc.markRead(friend.id);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChatScreen(friend: friend)),
          );
        },
      ),
    );
  }

  void _showOptions(
      BuildContext context, FriendService svc, ChatService chatSvc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  friend.pinned ? Icons.push_pin_outlined : Icons.push_pin,
                ),
                title: Text(
                  friend.pinned ? 'Unpin Friend' : 'Pin Friend',
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await svc.pinFriend(friend.id, !friend.pinned);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        friend.pinned
                            ? 'Unpinned ${friend.name}'
                            : 'Pinned ${friend.name}',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete Friend'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await svc.deleteFriend(friend.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text('Deleted ${friend.name} & chat history'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
