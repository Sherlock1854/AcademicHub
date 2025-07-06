import 'package:flutter/material.dart';
import '../models/forum_topic.dart';
import '../services/forum_service.dart';
import '../models/forum_post.dart';
import 'post_detail_screen.dart';

class PostListScreen extends StatelessWidget {
  final ForumTopic topic;
  const PostListScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: StreamBuilder<List<ForumPost>>(
        stream: ForumService().posts(topic.id),
        builder: (c, s) {
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          return ListView(
            children: s.data!.map((p) {
              return ListTile(
                title: Text(p.title),
                subtitle: Text('by ${p.author}'),
                onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                  builder: (_) => PostDetailScreen(post: p),
                )),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
