// lib/screens/post_list_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final Map<String, String> _userNamesCache = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesFilter(ForumPost p) {
    final q = _searchQuery.toLowerCase();
    return p.title.toLowerCase().contains(q);
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  /// Fetch the full name by looking up the user doc by UID.
  Future<String> _getFullName(String uid) async {
    if (_userNamesCache.containsKey(uid)) return _userNamesCache[uid]!;
    final snap = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    final data = snap.data();
    final fullName = '${data?['firstName'] ?? ''} ${data?['surname'] ?? ''}'.trim();
    _userNamesCache[uid] = fullName.isEmpty ? 'Unknown' : fullName;
    return _userNamesCache[uid]!;
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
          // ─── Search bar ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // ─── Posts list ─────────────────────
          Expanded(
            child: StreamBuilder<List<ForumPost>>(
              stream: ForumService().posts(widget.topic.id),
              builder: (context, snap) {
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
                    child: Text('No posts found', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final p = posts[i];
                    final createdAt = p.timestamp.toDate();

                    return FutureBuilder<String>(
                      future: _getFullName(p.author),
                      builder: (ctx, nameSnap) {
                        final fullName = nameSnap.data ?? 'Loading…';
                        final avatarUrl = p.userImageUrl.isNotEmpty
                            ? p.userImageUrl
                            : 'https://firebasestorage.googleapis.com/v0/b/academichub-c1068.appspot.com/o/profile%2Fdefault_user.png?alt=media';

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
                                // — Header: avatar + full name + time —
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(avatarUrl),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(fullName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          const SizedBox(height: 2),
                                          Text(_timeAgo(createdAt),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // — Only title, no body —
                                Text(p.title,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),

                                const SizedBox(height: 8),

                                // — Image carousel if images exist —
                                if (p.imageUrls.isNotEmpty)
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: PageView.builder(
                                      itemCount: p.imageUrls.length,
                                      itemBuilder: (_, idx) => ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          p.imageUrls[idx],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 12),

                                // — Actions: like & comment —
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up_alt_outlined),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.chat_bubble_outline),
                                      onPressed: () {
                                        Navigator.of(ctx).push(MaterialPageRoute(
                                            builder: (_) =>
                                                PostDetailScreen(post: p)));
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
                );
              },
            ),
          ),
        ],
      ),

      // ─── FAB to add post ─────────────────
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
