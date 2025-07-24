// lib/services/comment_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of comments for a given post, ordered by timestamp ascending.
  Stream<List<Comment>> commentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => Comment.fromDocument(doc))
        .toList());
  }

  /// Adds a new comment under a post, then increments the post's commentCount.
  /// Errors are logged so you can see permission or network issues.
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String avatarUrl,
    required String text,
  }) async {
    final postRef    = _firestore.collection('posts').doc(postId);
    final commentsRef = postRef.collection('comments');

    // 1) Write the comment with a client timestamp
    try {
      final newDoc = await commentsRef.add({
        'authorId': authorId,
        'avatarUrl': avatarUrl,
        'text': text,
        'timestamp': Timestamp.now(),
      });
      // Optionally you can await newDoc.get() here
    } catch (e, st) {
      print('❌ [CommentService] Failed to add comment: $e\n$st');
      rethrow;
    }

    // 2) Increment commentCount, but don't block if this fails
    try {
      await postRef.update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e, st) {
      print('⚠️ [CommentService] Failed to bump commentCount: $e\n$st');
    }
  }

  /// Deletes a comment and decrements the post's commentCount.
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final postRef    = _firestore.collection('posts').doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    try {
      await commentRef.delete();
    } catch (e, st) {
      print('❌ [CommentService] Failed to delete comment: $e\n$st');
      rethrow;
    }

    try {
      await postRef.update({
        'commentCount': FieldValue.increment(-1),
      });
    } catch (e, st) {
      print('⚠️ [CommentService] Failed to decrement commentCount: $e\n$st');
    }
  }
}
