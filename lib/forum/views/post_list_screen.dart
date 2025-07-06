import 'package:flutter/material.dart';
import '../models/forum_topic.dart';
import '../services/forum_service.dart';
import '../models/forum_post.dart';
import 'post_detail_screen.dart';
import 'add_post_dialog.dart';

class PostListScreen extends StatelessWidget {
  final ForumTopic topic;
  const PostListScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: StreamBuilder<List<ForumPost>>(
        stream: ForumService().posts(topic.id),
        builder: (c, snap) {
          switch (snap.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }
              final posts = snap.data!;
              if (posts.isEmpty) {
                return const Center(child: Text('No posts yet'));
              }
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (ctx, i) {
                  final p = posts[i];
                  return ListTile(
                    title: Text(p.title),
                    subtitle: Text('by ${p.author}'),
                    onTap: () => Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: p),
                      ),
                    ),
                  );
                },
              );
            default:
              return const SizedBox.shrink(); // unreachable
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_comment),
        onPressed: () => showDialog(
          context: ctx,
          builder: (_) => AddPostDialog(topicId: topic.id),
        ),
      ),
    );
  }
}
