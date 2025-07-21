// lib/screens/post_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forum_post.dart';

// Import your Friend model and ChatScreen:
import '../../friend/models/friend.dart';
import '../../chat/views/chat_screen.dart';  // adjust path if needed

class PostDetailScreen extends StatelessWidget {
  final ForumPost post;
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    final dt = post.timestamp.toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('by ${post.author}',
                style: const TextStyle(color: Colors.grey)),
            Text(DateFormat.yMMMd().add_jm().format(dt)),
            const SizedBox(height: 16),
            Text(post.body),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Chat with Gemini',
        child: const Icon(Icons.chat_bubble_outline),
        onPressed: () {
          // Create a dummy Friend for the bot:
          final botFriend = Friend(
            id: 'chatbot',
            name: 'Gemini Bot',
            lastText: '',
            lastIsImage: false,
            lastTimestamp: DateTime.now(),
            lastIsSender: false,
            avatarBase64: '',         // will use placeholder
            hasUnreadMessages: false,
            pinned: false,
          );

          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(friend: botFriend),
            ),
          );
        },
      ),
    );
  }
}
