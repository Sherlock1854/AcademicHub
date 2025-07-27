// lib/screens/post_list_screen.dart

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
  String _searchInput = '';
  String _searchQuery = '';
  PostSortOption _sortOption = PostSortOption.newest;
  final Map<String, String> _userNamesCache = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    setState(() {
      _searchQuery = _searchInput.trim().toLowerCase();
    });
  }

  bool _matchesFilter(ForumPost p) {
    return p.title.toLowerCase().contains(_searchQuery);
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  Future<String> _getFullName(String userId) async {
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    }
    final doc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final data = doc.data() ?? {};
    final full = '${data['firstName'] ?? ''} ${data['surname'] ?? ''}'.trim();
    _userNamesCache[userId] = full.isEmpty ? 'Unknown' : full;
    return _userNamesCache[userId]!;
  }

  void _sortPosts(List<ForumPost> posts) {
    switch (_sortOption) {
      case PostSortOption.newest:
        posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case PostSortOption.mostCommented:
        posts.sort(
          (a, b) => (b.commentCount ?? 0).compareTo(a.commentCount ?? 0),
        );
        break;
      case PostSortOption.mostLiked:
        posts.sort((a, b) => (b.likeCount ?? 0).compareTo(a.likeCount ?? 0));
        break;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 1,
        centerTitle: true,
        foregroundColor: Colors.black,
        title: Text(
          widget.topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<PostSortOption>(
            color: Colors.white,
            icon: Row(
              children: const [
                Icon(Icons.sort, color: Colors.black),
                SizedBox(width: 4),
                Text('Sort by', style: TextStyle(color: Colors.black)),
              ],
            ),
            onSelected: (val) => setState(() => _sortOption = val),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(
                    value: PostSortOption.mostCommented,
                    child: Text('Top comments'),
                  ),
                  PopupMenuItem(
                    value: PostSortOption.newest,
                    child: Text('Newest first'),
                  ),
                  PopupMenuItem(
                    value: PostSortOption.mostLiked,
                    child: Text('Most liked'),
                  ),
                ],
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.blue,
              textInputAction: TextInputAction.search,
              onChanged: (val) => _searchInput = val,
              onSubmitted: (_) => _applySearch(),
              decoration: InputDecoration(
                hintText: 'Search by title…',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: _applySearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),

          // ── Posts List ─────────────────────────────────────────
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
                final posts =
                    _searchQuery.isEmpty
                        ? [...allPosts]
                        : allPosts.where(_matchesFilter).toList();

                _sortPosts(posts);

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
                    final createdAt = p.timestamp.toDate();

                    return FutureBuilder<String>(
                      future: _getFullName(p.author),
                      builder: (ctx2, nameSnap) {
                        final fullName = nameSnap.data ?? 'Loading…';
                        final avatarUrl =
                            p.userImageUrl.isNotEmpty ? p.userImageUrl : '';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                          color: Colors.white,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(ctx2).push(
                                  MaterialPageRoute(
                                    builder: (_) => PostDetailScreen(post: p),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Header ───────────────────────
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.grey[200],
                                          child: ClipOval(
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/images/fail.png',
                                              image: avatarUrl,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              imageErrorBuilder:
                                                  (_, __, ___) => Image.asset(
                                                    'assets/images/fail.png',
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fullName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _timeAgo(createdAt),
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
                                    // ── Title ────────────────────────
                                    Text(
                                      p.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // ── Like & Comment ───────────────
                                    StreamBuilder<DocumentSnapshot>(
                                      stream:
                                          FirebaseFirestore.instance
                                              .collection('topics')
                                              .doc(widget.topic.id)
                                              .collection('posts')
                                              .doc(p.id)
                                              .snapshots(),
                                      builder: (ctx3, snap3) {
                                        if (!snap3.hasData) {
                                          return const SizedBox();
                                        }
                                        final data =
                                            snap3.data!.data()
                                                as Map<String, dynamic>;
                                        final likeCount =
                                            (data['likeCount'] as int?) ?? 0;
                                        final commentCount =
                                            (data['commentCount'] as int?) ?? 0;
                                        final likedBy = List<String>.from(
                                          data['likedBy'] ?? [],
                                        );
                                        final uid =
                                            FirebaseAuth
                                                .instance
                                                .currentUser
                                                ?.uid;
                                        final isLiked =
                                            uid != null &&
                                            likedBy.contains(uid);

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            OutlinedButton.icon(
                                              onPressed: () async {
                                                await ForumService().toggleLike(
                                                  topicId: widget.topic.id,
                                                  postId: p.id,
                                                );
                                              },
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.thumb_up
                                                    : Icons
                                                        .thumb_up_alt_outlined,
                                                color: Colors.blue,
                                              ),
                                              label: Text(
                                                '$likeCount',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Colors.blue,
                                                ),
                                                shape: const StadiumBorder(),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Navigator.of(ctx3).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) => PostDetailScreen(
                                                          post: p,
                                                        ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.comment_outlined,
                                                color: Colors.blue,
                                              ),
                                              label: Text(
                                                '$commentCount',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Colors.blue,
                                                ),
                                                shape: const StadiumBorder(),
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
        backgroundColor: Colors.white,
        child: const Icon(Icons.add_comment, color: Colors.blue),
        onPressed:
            () => showDialog(
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
            itemBuilder:
                (_, idx) => ClipRRect(
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
