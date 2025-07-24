// lib/screens/post_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/forum_post.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';

class PostDetailScreen extends StatefulWidget {
  final ForumPost post;
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _commentService = CommentService();
  late final PageController _pageController;
  int _currentPage = 0;

  // Cache for full names
  final Map<String, String> _userNamesCache = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<String> _getFullName(String userId) async {
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    }
    final snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();
    final data = snap.data() ?? {};
    final fullName =
    '${data['firstName'] ?? ''} ${data['surname'] ?? ''}'.trim();
    _userNamesCache[userId] = fullName.isEmpty ? 'Unknown' : fullName;
    return _userNamesCache[userId]!;
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0)    return '${diff.inDays} day${diff.inDays>1?'s':''} ago';
    if (diff.inHours > 0)   return '${diff.inHours} hour${diff.inHours>1?'s':''} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min${diff.inMinutes>1?'s':''} ago';
    return 'just now';
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    // TODO: pull real current user info
    const currentUserName   = 'Current User';
    const currentUserAvatar = 'https://via.placeholder.com/150';

    await _commentService.addComment(
      postId: widget.post.id,
      authorName: currentUserName,
      avatarUrl: currentUserAvatar,
      text: text,
    );
    _commentController.clear();
  }

  @override
  Widget build(BuildContext ctx) {
    final post   = widget.post;
    final dt     = post.timestamp.toDate();
    final images = post.imageUrls ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {/* TODO: menu */},
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // — Header: avatar + resolved full name
            FutureBuilder<String>(
              future: _getFullName(post.author),
              builder: (ctx, snap) {
                final name = snap.data ?? 'Loading…';
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(post.userImageUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_timeAgo(dt),
                            style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // — Title
            Text(post.title,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            // — Image carousel with fallback
            if (images.isNotEmpty)
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (ctx, i) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/fail.png',
                            image: images[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      },
                    ),
                    if (images.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentPage + 1}/${images.length}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            if (images.isNotEmpty) const SizedBox(height: 16),

            // — Body
            Text(post.body, style: const TextStyle(fontSize: 16, height: 1.4)),

            const SizedBox(height: 24),

            // — Engagement row (rounded buttons)
            StreamBuilder<List<Comment>>(
              stream: _commentService.commentsStream(post.id),
              builder: (ctx, snap) {
                final comments = snap.data ?? [];
                return Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {/* TODO: like */},
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('0'), // placeholder like count
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {/* TODO: scroll to comments */},
                      icon: const Icon(Icons.comment_outlined),
                      label: Text('${comments.length}'),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // — Comments header
            const Text('Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // — Comments list
            StreamBuilder<List<Comment>>(
              stream: _commentService.commentsStream(post.id),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snap.data!;
                if (comments.isEmpty) {
                  return const Text('Be the first to comment.',
                      style: TextStyle(color: Colors.grey));
                }
                return Column(
                  children: comments.map(_buildComment).toList(),
                );
              },
            ),
          ],
        ),
      ),

      // — Add comment input
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment…',
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _submitComment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComment(Comment c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(c.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(c.authorName,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold))),
                    Text(_timeAgo(c.timestamp),
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(c.text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
