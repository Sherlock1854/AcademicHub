// lib/services/comment_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/comment.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final HttpsCallable _sendPush = FirebaseFunctions.instance
      .httpsCallable('sendPushNotification');

  /// Stream of comments under topics/{topicId}/posts/{postId}/comments
  Stream<List<Comment>> commentsStream({
    required String topicId,
    required String postId,
  }) {
    final ref = _firestore
        .collection('topics') // ← root collection
        .doc(topicId)
        .collection('posts')
        .doc(postId)
        .collection('comments');

    return ref
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Comment.fromDoc(d)).toList());
  }

  /// Adds a comment under topics/{topicId}/posts/{postId}/comments
  /// and increments that post's commentCount.
  Future<void> addComment({
    required String topicId,
    required String postId,
    required String authorId,
    required String avatarUrl,
    required String text,
  }) async {
    final postRef = _firestore
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .doc(postId);
    final commentsRef = postRef.collection('comments');

    // 1) Write the comment
    await commentsRef.add({
      'authorId': authorId,
      'avatarUrl': avatarUrl,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2) Bump the post's commentCount
    await postRef.update({'commentCount': FieldValue.increment(1)});

    final postSnap = await postRef.get();
    if (postSnap.exists) {
      final data = postSnap.data()!;
      final targetUid = data['author'] as String?;
      if (targetUid != null && targetUid != authorId) {
        await _sendPush.call({
          'targetUserId': targetUid,
          'title': 'New Comment',
          'body': text.length > 50 ? text.substring(0, 47) + '…' : text,
        });
      }
    }
  }

  /// Deletes a comment and decrements the post's commentCount.
  Future<void> deleteComment({
    required String topicId,
    required String postId,
    required String commentId,
  }) async {
    final postRef = _firestore
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .doc(postId);
    final commentRef = postRef.collection('comments').doc(commentId);

    await commentRef.delete();
    await postRef.update({'commentCount': FieldValue.increment(-1)});
  }
}
