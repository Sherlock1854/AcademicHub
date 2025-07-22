// lib/screens/post_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/forum_topic.dart';
import '../models/forum_post.dart';
import '../services/forum_service.dart';
import 'post_detail_screen.dart';
import 'add_post_dialog.dart';

class PostListScreen extends StatefulWidget {
  final ForumTopic topic;
  const PostListScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<PostListScreen> createState() => _PostListScreenState();
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
    return p.title.toLowerCase().contains(q) ||
        p.author.toLowerCase().contains(q);
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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

                final allPosts = snap.data!;
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

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final p = posts[i];
                    // convert Firestore Timestamp to DateTime
                    final dt = p.timestamp.toDate();

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // header: avatar + author + time
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                    p.userImageUrl.isNotEmpty
                                        ? p.userImageUrl
                                        : 'assets/images/fail.png',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.author,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _timeAgo(dt),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // post title (bold) + body (regular)
                            Text(
                              p.title,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.body,
                              style: const TextStyle(fontSize: 15),
                            ),

                            const SizedBox(height: 12),

                            // actions: like & comment
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.thumb_up_alt_outlined),
                                  onPressed: () {
                                    // TODO: handle like
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                      Icons.chat_bubble_outline),
                                  onPressed: () {
                                    Navigator.of(ctx).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PostDetailScreen(post: p),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
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
          builder: (_) =>
              AddPostDialog(topicId: widget.topic.id),
        ),
      ),
    );
  }
}
