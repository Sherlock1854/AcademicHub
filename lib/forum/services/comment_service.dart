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
        .map((snap) =>
        snap.docs.map((doc) => Comment.fromDocument(doc)).toList());
  }

  /// Adds a new comment under a post.
  Future<void> addComment({
    required String postId,
    required String authorName,
    required String avatarUrl,
    required String text,
  }) {
    final comment = Comment(
      id: '', // Firestore will assign
      authorName: authorName,
      avatarUrl: avatarUrl,
      text: text,
      timestamp: DateTime.now(),
    );

    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add(comment.toMap());
  }

  /// (Optional) Delete a comment by its ID.
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}
