// lib/screens/post_detail_screen.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  int  _currentPage   = 0;
  int  _likeCount     = 0;
  int  _commentCount  = 0;
  bool _isLiked       = false;
  bool _isLiking      = false;
  bool _canEditPost   = false;
  bool _isAdmin       = false;
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
    _body  = widget.post.body;
    _myUid = FirebaseAuth.instance.currentUser?.uid;
    _loadPostState();
    _checkPermissions();
  }

  Future<void> _loadPostState() async {
    final user = FirebaseAuth.instance.currentUser;
    final snap = await _postRef.get();
    if (!snap.exists) return;
    final data         = snap.data()! as Map<String, dynamic>;
    final likedBy      = List<String>.from(data['likedBy'] ?? <String>[]);
    final likeCount    = (data['likeCount']    as int?) ?? 0;
    final commentCount = (data['commentCount'] as int?) ?? 0;
    setState(() {
      _likeCount    = likeCount;
      _commentCount = commentCount;
      _isLiked      = user != null && likedBy.contains(user.uid);
    });
  }

  Future<void> _checkPermissions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token    = await user.getIdTokenResult();
    _isAdmin       = token.claims?['admin'] == true;
    final isAuthor = user.uid == widget.post.author;
    setState(() {
      _canEditPost = isAuthor || _isAdmin;
    });
  }

  Future<String> _getFullName(String userId) async {
    if (_userNamesCache.containsKey(userId)) return _userNamesCache[userId]!;
    final snap = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final data = snap.data() ?? {};
    final full = '${data['firstName'] ?? ''} ${data['surname'] ?? ''}'.trim();
    final name = full.isEmpty ? 'Unknown' : full;
    _userNamesCache[userId] = name;
    return name;
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays    > 0) return '${diff.inDays} day${diff.inDays>1?"s":""} ago';
    if (diff.inHours   > 0) return '${diff.inHours} hour${diff.inHours>1?"s":""} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min${diff.inMinutes>1?"s":""} ago';
    return 'just now';
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isLiking) return;
    setState(() => _isLiking = true);
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final fresh = await tx.get(_postRef);
        final data  = fresh.data()! as Map<String, dynamic>;
        final list  = List<String>.from(data['likedBy'] ?? <String>[]);
        var   count = (data['likeCount'] as int?) ?? 0;
        if (list.contains(user.uid)) {
          list.remove(user.uid); count--;
        } else {
          list.add(user.uid);    count++;
        }
        tx.update(_postRef, {'likedBy': list, 'likeCount': count});
        setState(() {
          _isLiked   = list.contains(user.uid);
          _likeCount = count;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not update like: $e')));
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
      final doc = await _commentsRef.add({
        'authorId' : user.uid,
        'avatarUrl': user.photoURL ?? '',
        'text'     : text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _postRef.update({'commentCount': FieldValue.increment(1)});
      setState(() => _commentCount++);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
    }
  }

  Future<void> _showEditDialog() async {
    final titleCtrl = TextEditingController(text: _title);
    final bodyCtrl  = TextEditingController(text: _body);
    final keepUrls  = List<String>.from(widget.post.imageUrls);
    final removed   = <String>[];
    final added     = <File>[];

    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState2) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: const Text('Edit Post'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                  const SizedBox(height: 8),
                  TextField(controller: bodyCtrl,  decoration: const InputDecoration(labelText: 'Body')),
                  const SizedBox(height: 16),
                  // Add Image Button
                  TextButton.icon(
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Image'),
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState2(() => added.add(File(picked.path)));
                      }
                    },
                  ),
                  // Thumbnails
                  if (keepUrls.isNotEmpty || added.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: keepUrls.length + added.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          if (i < keepUrls.length) {
                            final url = keepUrls[i];
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 2, right: 2,
                                  child: GestureDetector(
                                    onTap: () => setState2(() {
                                      keepUrls.removeAt(i);
                                      removed.add(url);
                                    }),
                                    child: Container(
                                      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
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
                                child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 2, right: 2,
                                child: GestureDetector(
                                  onTap: () => setState2(() {
                                    added.removeAt(i - keepUrls.length);
                                  }),
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('Save')),
          ],
        ),
      ),
    );
    if (save != true) return;

    // upload new files
    final newUrls = <String>[];
    for (final file in added) {
      final ref = FirebaseStorage.instance
          .ref('post_images/${widget.post.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      newUrls.add(await ref.getDownloadURL());
    }
    // delete removed
    for (final url in removed) {
      try { await FirebaseStorage.instance.refFromURL(url).delete(); } catch (_) {}
    }
    final finalUrls = [...keepUrls, ...newUrls];

    await _forumService.updatePost(
      topicId:   widget.post.topicId,
      postId:    widget.post.id,
      title:     titleCtrl.text.trim(),
      body:      bodyCtrl.text.trim(),
      imageUrls: finalUrls,
    );
    setState(() {
      _title = titleCtrl.text.trim();
      _body  = bodyCtrl.text.trim();
      widget.post.imageUrls
        ..clear()
        ..addAll(finalUrls);
    });
  }

  Future<void> _confirmDeletePost() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This will delete the post and all its comments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await _forumService.deletePost(
        topicId: widget.post.topicId,
        postId:  widget.post.id,
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _showEditCommentDialog(Comment c) async {
    final ctrl = TextEditingController(text: c.text);
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(controller: ctrl, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('Save')),
        ],
      ),
    );
    if (save == true) {
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
        title: const Text('Delete comment?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),  child: const Text('Delete')),
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
    final isAuthor  = c.authorId == _myUid;
    final canDelete = isAuthor || _isAdmin || (widget.post.author == _myUid);
    final canEdit   = isAuthor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(c.avatarUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Builder( // Use a safe context here
              builder: (safeCtx) => FutureBuilder<String>(
                future: _getFullName(c.authorId),
                builder: (ctx, snap) {
                  final name = snap.data ?? 'Loading…';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          Text(_timeAgo(c.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          if (canEdit || canDelete)
                            PopupMenuButton<String>(
                              onSelected: (choice) {
                                if (choice == 'edit')   _showEditCommentDialog(c);
                                if (choice == 'delete') _confirmDeleteComment(c.id);
                              },
                              itemBuilder: (_) => [
                                if (canEdit)   const PopupMenuItem(value: 'edit',   child: Text('Edit')),
                                if (canDelete) const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(c.text),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dt     = widget.post.timestamp.toDate();
    final images = widget.post.imageUrls;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_title, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: _canEditPost
            ? [
          PopupMenuButton<String>(
            onSelected: (choice) {
              if (choice == 'edit')   _showEditDialog();
              if (choice == 'delete') _confirmDeletePost();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit',   child: Text('Edit Page')),
              PopupMenuItem(value: 'delete', child: Text('Delete Post')),
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
            // Author header
            FutureBuilder<String>(
              future: _getFullName(widget.post.author),
              builder: (ctx, snap) {
                final name = snap.data ?? 'Loading…';
                return Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.post.userImageUrl)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_timeAgo(dt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            // Title & body
            Text(_title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Image carousel
            if (images.isNotEmpty) ...[
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          images[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (_, child, prog) => prog == null
                              ? child
                              : const Center(child: CircularProgressIndicator()),
                          errorBuilder: (_, __, ___) =>
                              Image.asset('assets/images/fail.png', fit: BoxFit.cover, width: double.infinity),
                        ),
                      ),
                    ),
                    if (images.length > 1)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                          child: Text('${_currentPage+1}/${images.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(_body, style: const TextStyle(fontSize: 16, height: 1.4)),
            const SizedBox(height: 24),
            // Like & comment buttons
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _isLiking ? null : _toggleLike,
                  icon: Icon(_isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                  label: Text('$_likeCount'),
                  style: OutlinedButton.styleFrom(shape: const StadiumBorder(), side: const BorderSide(color: Colors.grey)),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment_outlined),
                  label: Text('$_commentCount'),
                  style: OutlinedButton.styleFrom(shape: const StadiumBorder(), side: const BorderSide(color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _commentsRef.orderBy('timestamp', descending: true).snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Text('Be the first to comment.', style: TextStyle(color: Colors.grey));
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
          left: 16, right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 8,
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
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _submitComment(),
              ),
            ),
            IconButton(icon: const Icon(Icons.send), onPressed: _submitComment),
          ],
        ),
      ),
    );
  }
}
