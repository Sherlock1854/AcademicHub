// lib/screens/widgets/friend_list_item.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/friend.dart';
import '../../../chat/views/chat_screen.dart';

class FriendListItem extends StatelessWidget {
  final Friend friend;
  const FriendListItem({Key? key, required this.friend}) : super(key: key);

  String _formatTimestamp(DateTime? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts).inDays;
    if (diff == 0) return DateFormat('h:mm a').format(ts);
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return DateFormat('MMM d').format(ts);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = friend.lastIsImage
        ? '[picture]'
        : (friend.lastText ?? '');
    final time = _formatTimestamp(friend.lastTimestamp);

    final avatar = friend.avatarBase64.isNotEmpty
        ? CircleAvatar(
      radius: 24,
      backgroundImage:
      MemoryImage(base64Decode(friend.avatarBase64)),
    )
        : const CircleAvatar(
      radius: 24,
      child: Icon(Icons.person),
    );

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: avatar,
      title: Text(
        friend.name,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600),
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
            Text(time,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          if (friend.hasUnreadMessages)
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                  color: Colors.blue, shape: BoxShape.circle),
            ),
        ],
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(friend: friend),
        ),
      ),
    );
  }
}
