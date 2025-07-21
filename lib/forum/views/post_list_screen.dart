// lib/screens/post_list_screen.dart

import 'package:flutter/material.dart';
import '../models/forum_topic.dart';
import '../services/forum_service.dart';
import '../models/forum_post.dart';
import 'post_detail_screen.dart';
import 'add_post_dialog.dart';

class PostListScreen extends StatefulWidget {
  final ForumTopic topic;
  const PostListScreen({Key? key, required this.topic}) : super(key: key);

  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(ForumPost p) {
    final q = _searchQuery.toLowerCase();
    return p.title.toLowerCase().contains(q)
        || p.author.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // ─── Search bar ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or author…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // ─── List of posts ─────────────────────────────────
          Expanded(
            child: StreamBuilder<List<ForumPost>>(
              stream: ForumService().posts(widget.topic.id),
              builder: (c, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                // original list
                final allPosts = snap.data!;
                // apply filter if any
                final posts = _searchQuery.isEmpty
                    ? allPosts
                    : allPosts.where(_matchesFilter).toList();

                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No posts found',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
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
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_comment),
        onPressed: () => showDialog(
          context: ctx,
          builder: (_) => AddPostDialog(topicId: widget.topic.id),
        ),
      ),
    );
  }
}
