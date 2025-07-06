import 'package:flutter/material.dart';
import '../models/forum_post.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatelessWidget {
  final ForumPost post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext ctx) {
    final dt = post.timestamp.toDate();
    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('by ${post.author}', style: const TextStyle(color: Colors.grey)),
            Text(DateFormat.yMMMd().add_jm().format(dt)),
            const SizedBox(height: 16),
            Text(post.body),
          ],
        ),
      ),
    );
  }
}
