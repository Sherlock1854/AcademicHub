import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/forum_topic.dart';
import '../models/forum_post.dart';
import '../services/forum_service.dart';
import 'post_detail_screen.dart';
import 'add_post_dialog.dart';

enum PostSortOption { newest, mostCommented, mostLiked }

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
  PostSortOption _sortOption = PostSortOption.newest;

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

  Future<String> _getFullName(String userId) async {
    if (_userNamesCache.containsKey(userId)) return _userNamesCache[userId]!;
    final snap = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final data = snap.data();
    final fullName = '${data?['firstName'] ?? ''} ${data?['surname'] ?? ''}'.trim();
    _userNamesCache[userId] = fullName.isEmpty ? 'Unknown' : fullName;
    return _userNamesCache[userId]!;
  }

  void _sortPosts(List<ForumPost> posts) {
    switch (_sortOption) {
      case PostSortOption.newest:
        posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case PostSortOption.mostCommented:
        posts.sort((a, b) => (b.commentCount ?? 0).compareTo(a.commentCount ?? 0));
        break;
      case PostSortOption.mostLiked:
        posts.sort((a, b) => (b.likeCount ?? 0).compareTo(a.likeCount ?? 0));
        break;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          PopupMenuButton<PostSortOption>(
            icon: Row(
              children: const [
                Icon(Icons.sort, color: Colors.black),
                SizedBox(width: 4),
                Text('Sort by', style: TextStyle(color: Colors.black)),
              ],
            ),
            onSelected: (val) => setState(() => _sortOption = val),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: PostSortOption.mostCommented,
                child: const Text('Top comments'),
              ),
              PopupMenuItem(
                value: PostSortOption.newest,
                child: const Text('Newest first'),
              ),
              PopupMenuItem(
                value: PostSortOption.mostLiked,
                child: const Text('Most liked'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                    ? [...allPosts]
                    : allPosts.where(_matchesFilter).toList();

                _sortPosts(posts);

                if (posts.isEmpty) {
                  return const Center(
                    child: Text('No posts found', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => PostDetailScreen(post: p)));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(height: 2),
                                              Text(_timeAgo(createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    if (p.imageUrls.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {},
                                        child: _ImageCarousel(imageUrls: p.imageUrls),
                                      ),
                                    const SizedBox(height: 12),
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('topics')
                                          .doc(widget.topic.id)
                                          .collection('posts')
                                          .doc(p.id)
                                          .snapshots(),
                                      builder: (ctx, snap) {
                                        if (!snap.hasData) return const SizedBox();
                                        final data = snap.data!.data() as Map<String, dynamic>;
                                        final likeCount = (data['likeCount'] ?? 0) as int;
                                        final commentCount = (data['commentCount'] ?? 0) as int;
                                        final likedBy = List<String>.from(data['likedBy'] ?? <String>[]);
                                        final uid = FirebaseAuth.instance.currentUser?.uid;
                                        final isLiked = uid != null && likedBy.contains(uid);

                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () async {
                                                if (uid == null) return;
                                                final ref = FirebaseFirestore.instance
                                                    .collection('topics')
                                                    .doc(widget.topic.id)
                                                    .collection('posts')
                                                    .doc(p.id);
                                                await FirebaseFirestore.instance.runTransaction((transaction) async {
                                                  final fresh = await transaction.get(ref);
                                                  final data = fresh.data() as Map<String, dynamic>;
                                                  final list = List<String>.from(data['likedBy'] ?? []);
                                                  var count = (data['likeCount'] ?? 0) as int;

                                                  if (list.contains(uid)) {
                                                    list.remove(uid);
                                                    count--;
                                                  } else {
                                                    list.add(uid);
                                                    count++;
                                                  }
                                                  transaction.update(ref, {'likedBy': list, 'likeCount': count});
                                                });
                                              },
                                              icon: Icon(isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                                              label: Text('$likeCount'),
                                              style: OutlinedButton.styleFrom(
                                                shape: const StadiumBorder(),
                                                side: const BorderSide(color: Colors.grey),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Navigator.of(ctx).push(MaterialPageRoute(
                                                  builder: (_) => PostDetailScreen(post: p),
                                                ));
                                              },
                                              icon: const Icon(Icons.comment_outlined),
                                              label: Text('$commentCount'),
                                              style: OutlinedButton.styleFrom(
                                                shape: const StadiumBorder(),
                                                side: const BorderSide(color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
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

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageCarousel({required this.imageUrls});

  @override
  State<_ImageCarousel> createState() => __ImageCarouselState();
}

class __ImageCarouselState extends State<_ImageCarousel> {
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (idx) => setState(() => _current = idx),
            itemBuilder: (_, idx) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imageUrls[idx],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_current + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
