// lib/screens/post_detail_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../chat/views/chat_screen.dart';
import '../../friend/models/friend.dart';
import '../models/forum_post.dart';
import '../models/comment.dart';
import '../services/forum_service.dart';

class PostDetailScreen extends StatefulWidget {
  final ForumPost post;
  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  late final PageController _pageController;
  final _userNamesCache = <String, String>{};
  final _forumService = ForumService();

  int _currentPage = 0;
  int _commentCount = 0;
  bool _isLiking = false;
  bool _canEditPost = false;
  bool _isAdmin = false;
  String? _myUid;

  late String _title;
  late String _body;

  DocumentReference get _postRef => FirebaseFirestore.instance
      .collection('topics')
      .doc(widget.post.topicId)
      .collection('posts')
      .doc(widget.post.id);
  CollectionReference get _commentsRef => _postRef.collection('comments');

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _title = widget.post.title;
    _body = widget.post.body;
    _myUid = FirebaseAuth.instance.currentUser?.uid;
    _loadPostState();
    _checkPermissions();
  }

  Future<void> _loadPostState() async {
    final user = FirebaseAuth.instance.currentUser;
    final snap = await _postRef.get();
    if (!snap.exists) return;
    final data = snap.data()! as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? <String>[]);
    final likeCount = (data['likeCount'] as int?) ?? 0;
    final commentCount = (data['commentCount'] as int?) ?? 0;
    setState(() {
      _commentCount = commentCount;
    });
  }

  Future<void> _checkPermissions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token = await user.getIdTokenResult();
    _isAdmin = token.claims?['admin'] == true;
    final isAuthor = user.uid == widget.post.author;
    setState(() {
      _canEditPost = isAuthor || _isAdmin;
    });
  }

  Future<String> _getFullName(String userId) async {
    if (_userNamesCache.containsKey(userId)) return _userNamesCache[userId]!;
    final snap =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final data = snap.data() ?? {};
    final full = '${data['firstName'] ?? ''} ${data['surname'] ?? ''}'.trim();
    final name = full.isEmpty ? 'Unknown' : full;
    _userNamesCache[userId] = name;
    return name;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? "s" : ""} ago';
    if (diff.inHours > 0)
      return '${diff.inHours} hour${diff.inHours > 1 ? "s" : ""} ago';
    if (diff.inMinutes > 0)
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? "s" : ""} ago';
    return 'just now';
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isLiking) return;
    setState(() => _isLiking = true);
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final fresh = await tx.get(_postRef);
        final data = fresh.data()! as Map<String, dynamic>;
        final list = List<String>.from(data['likedBy'] ?? <String>[]);
        var count = (data['likeCount'] as int?) ?? 0;
        if (list.contains(user.uid)) {
          list.remove(user.uid);
          count--;
        } else {
          list.add(user.uid);
          count++;
        }
        tx.update(_postRef, {'likedBy': list, 'likeCount': count});
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update like: $e')));
    } finally {
      setState(() => _isLiking = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _commentsRef.add({
        'authorId': user.uid,
        'avatarUrl': user.photoURL ?? '',
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _postRef.update({'commentCount': FieldValue.increment(1)});
      setState(() => _commentCount++);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
    }
  }

  Future<void> _showEditDialog() async {
    final titleCtrl = TextEditingController(text: _title);
    final bodyCtrl = TextEditingController(text: _body);
    final keepUrls = List<String>.from(widget.post.imageUrls);
    final removed = <String>[];
    final added = <File>[];

    final save = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),
            backgroundColor: Colors.white,
            child: StatefulBuilder(
              builder:
                  (ctx2, setState2) => ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx2).size.height * 0.8,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Edit Post',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title field
                          TextField(
                            controller: titleCtrl,
                            decoration: InputDecoration(
                              hintText: 'Title',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Body field
                          TextField(
                            controller: bodyCtrl,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Body',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Add Image button
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                              );
                              if (picked != null) {
                                setState2(() => added.add(File(picked.path)));
                              }
                            },
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.blue,
                            ),
                            label: const Text(
                              'Add Image',
                              style: TextStyle(color: Colors.blue),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),

                          // — if you have existing images or newly added ones, show previews here —
                          if (keepUrls.isNotEmpty || added.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 80,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: keepUrls.length + added.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 8),
                                itemBuilder: (ctx, i) {
                                  if (i < keepUrls.length) {
                                    final url = keepUrls[i];
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            url,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap:
                                                () => setState2(() {
                                                  keepUrls.removeAt(i);
                                                  removed.add(url);
                                                }),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  final file = added[i - keepUrls.length];
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          file,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap:
                                              () => setState2(
                                                () => added.removeAt(
                                                  i - keepUrls.length,
                                                ),
                                              ),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Cancel
                              OutlinedButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Save
                              OutlinedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blue),
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
    );

    if (save != true) return;

    // upload new files
    final newUrls = <String>[];
    for (final file in added) {
      final ref = FirebaseStorage.instance.ref(
        'post_images/${widget.post.id}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(file);
      newUrls.add(await ref.getDownloadURL());
    }
    // delete removed
    for (final url in removed) {
      try {
        await FirebaseStorage.instance.refFromURL(url).delete();
      } catch (_) {}
    }
    final finalUrls = [...keepUrls, ...newUrls];

    await _forumService.updatePost(
      topicId: widget.post.topicId,
      postId: widget.post.id,
      title: titleCtrl.text.trim(),
      body: bodyCtrl.text.trim(),
      imageUrls: finalUrls,
    );
    setState(() {
      _title = titleCtrl.text.trim();
      _body = bodyCtrl.text.trim();
      widget.post.imageUrls
        ..clear()
        ..addAll(finalUrls);
    });
  }

  Future<void> _confirmDeletePost() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,            // white dialog
        title: const Text('Delete post?'),
        content: const Text(
          'This will delete the post and all its comments.',
        ),
        actions: [
          // Cancel button: white bg, blue text & border
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),

          // Delete button: red bg, white text & red border
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _forumService.deletePost(
        topicId: widget.post.topicId,
        postId: widget.post.id,
      );
      Navigator.of(context).pop(); // go back
    }
  }

  Future<void> _showEditCommentDialog(Comment c) async {
    final ctrl = TextEditingController(text: c.text);

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Comment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type your comment',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  // Save
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (save == true && ctrl.text.trim().isNotEmpty) {
      await _commentsRef.doc(c.id).update({
        'text': ctrl.text.trim(),
        'editedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _confirmDeleteComment(String commentId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,

        // 1) Push the title up
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: const Text(
          'Delete comment?',
          textAlign: TextAlign.left,           // left-align the title
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // 2) Push the content right under the title
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        content: const Text(
          'This cannot be undone.',
          textAlign: TextAlign.left,           // left-align the body text
        ),

        // 3) Some breathing room before the buttons
        actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),

        actions: [
          // Cancel
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),

          // Delete
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _commentsRef.doc(commentId).delete();
      await _postRef.update({'commentCount': FieldValue.increment(-1)});
      setState(() => _commentCount--);
    }
  }

  Widget _buildComment(Comment c) {
    final isAuthor = c.authorId == _myUid;
    final canDelete = isAuthor || _isAdmin || (widget.post.author == _myUid);
    final canEdit = isAuthor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // a bit tighter overall
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar nudged down
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: Image.network(
                  c.avatarUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Image.asset(
                        'assets/images/fail.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name/time line + comment text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + time + menu
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _getFullName(c.authorId),
                        builder: (ctx, snap) {
                          final name = snap.data ?? 'Loading…';
                          return Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ),
                    Text(
                      _timeAgo(c.timestamp),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (canEdit || canDelete)
                      PopupMenuButton<String>(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onSelected: (choice) {
                          if (choice == 'edit') _showEditCommentDialog(c);
                          if (choice == 'delete') _confirmDeleteComment(c.id);
                        },
                        itemBuilder:
                            (_) => [
                              if (canEdit)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                              if (canDelete)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                            ],
                      ),
                  ],
                ),

                // Shrunk gap
                const SizedBox(height: 0),

                // Comment body
                Text(c.text, style: const TextStyle(fontSize: 14, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dt = widget.post.timestamp.toDate();
    final images = widget.post.imageUrls;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_title, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
        elevation: 1,
        actions:
            _canEditPost
                ? [
                  PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (choice) {
                      if (choice == 'edit') _showEditDialog();
                      if (choice == 'delete') _confirmDeletePost();
                    },
                    itemBuilder:
                        (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Post'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete Post'),
                          ),
                        ],
                  ),
                ]
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _getFullName(widget.post.author),
              builder: (ctx, snap) {
                final name = snap.data ?? 'Loading…';
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: Image.network(
                          widget.post.userImageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stack) {
                            return Image.asset(
                              'assets/images/fail.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _timeAgo(dt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              _title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (images.isNotEmpty) ...[
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder:
                          (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              images[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder:
                                  (_, child, prog) =>
                                      prog == null
                                          ? child
                                          : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                              errorBuilder:
                                  (_, __, ___) => Image.asset(
                                    'assets/images/fail.png',
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                    ),
                    if (images.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentPage + 1}/${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(_body, style: const TextStyle(fontSize: 16, height: 1.4)),
            const SizedBox(height: 24),
            StreamBuilder<DocumentSnapshot>(
              stream: _postRef.snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox();
                final data = snap.data!.data() as Map<String, dynamic>;
                final likeCount = (data['likeCount'] as int?) ?? 0;
                final commentCount = (data['commentCount'] as int?) ?? 0;
                final likedBy = List<String>.from(
                  data['likedBy'] ?? <String>[],
                );
                final isLiked = _myUid != null && likedBy.contains(_myUid);

                return Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed:
                          () => _forumService.toggleLike(
                            topicId: widget.post.topicId,
                            postId: widget.post.id,
                          ),
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: Colors.blue,
                      ),
                      label: Text(
                        '$likeCount',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        shape: const StadiumBorder(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.comment_outlined,
                        color: Colors.blue,
                      ),
                      label: Text(
                        '$commentCount',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream:
                  _commentsRef
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Text(
                    'Be the first to comment.',
                    style: TextStyle(color: Colors.grey),
                  );
                }
                final comments = docs.map((d) => Comment.fromDoc(d)).toList();
                return Column(children: comments.map(_buildComment).toList());
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 8,
        ),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment…',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _submitComment,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Chat with Gemini',
        backgroundColor: Colors.white, // white circle
        child: const Icon(
          Icons.smart_toy, // robot/AI icon
          color: Colors.blue, // blue icon
          size: 28,
        ),
        onPressed: () {
          // Create a dummy Friend for the bot:
          final botFriend = Friend(
            id: 'chatbot',
            name: 'Gemini Bot',
            lastText: '',
            lastIsImage: false,
            lastTimestamp: DateTime.now(),
            lastIsSender: false,
            avatarUrl: '', // <-- use avatarUrl, not avatarBase64
            hasUnreadMessages: false,
            pinned: false,
          );

          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChatScreen(friend: botFriend)),
          );
        },
      ),
    );
  }
}
