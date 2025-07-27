// lib/services/forum_service.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/forum_topic.dart';
import '../models/forum_post.dart';

class ForumService {
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final HttpsCallable _notify =
  FirebaseFunctions.instance.httpsCallable('sendPushNotification');

  /// Stream of all topics
  Stream<List<ForumTopic>> topics() {
    return _db
        .collection('topics')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => ForumTopic.fromDoc(d)).toList()
    );
  }

  /// Stream of posts under a topic
  Stream<List<ForumPost>> posts(String topicId) {
    return _db
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => ForumPost.fromDoc(d)).toList()
    );
  }

  /// Create a topic with optional image file.
  /// - Creates the Firestore doc to get its ID.
  /// - Uploads [iconFile] to Storage under topic_icons/{topicId}.jpg (if provided).
  /// - Updates the Firestore doc with the resulting download URL.
  Future<void> addTopic({
    required String title,
    File? iconFile,
  }) async {
    // 1) Create topic doc
    final docRef = await _db.collection('topics').add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'iconUrl': null,  // placeholder
    });

    // 2) If there's an image, upload and capture its public URL
    String? publicUrl;
    if (iconFile != null) {
      final storageRef = _storage.ref('topic_icons/${docRef.id}.jpg');
      await storageRef.putFile(iconFile);
      publicUrl = await storageRef.getDownloadURL();
    }

    // 3) Write back the URL (if any)
    if (publicUrl != null) {
      await docRef.update({'iconUrl': publicUrl});
    }
  }

  /// Add a post under a given topic, including optional attached images.
  Future<void> addPost({
    required String topicId,
    required String author,         // stores the UID
    required String title,
    required String body,
    required String userImageUrl,   // avatar URL
    List<String>? imageUrls,        // newly added param
  }) async {
    await _db
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .add({
      'topicId':      topicId,
      'author':       author,
      'title':        title,
      'body':         body,
      'timestamp':    FieldValue.serverTimestamp(),
      'userImageUrl': userImageUrl,
      'imageUrls':    imageUrls ?? <String>[],  // save empty list if null
    });
  }

  /// Update an existing post's title, body, or images.
  Future<void> updatePost({
    required String topicId,
    required String postId,
    String? title,
    String? body,
    List<String>? imageUrls,
  }) async {
    final docRef = _db
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .doc(postId);

    final data = <String, dynamic>{};
    if (title != null)     data['title']     = title;
    if (body != null)      data['body']      = body;
    if (imageUrls != null) data['imageUrls'] = imageUrls;

    if (data.isNotEmpty) {
      await docRef.update(data);
    }
  }

  /// Delete a post and all its comments under topics/{topicId}/posts/{postId}
  Future<void> deletePost({
    required String topicId,
    required String postId,
  }) async {
    final postRef = _db
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .doc(postId);

    // batch-delete comments then delete the post
    final batch = _db.batch();
    final commentsSnap = await postRef.collection('comments').get();
    for (var doc in commentsSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(postRef);
    await batch.commit();
  }

  /// Toggles the like state for [postId] in [topicId], bumps the count,
  /// and sends a push to the post author if it’s a new like.
  Future<void> toggleLike({
    required String topicId,
    required String postId,
  }) async {
    final postRef = _db
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .doc(postId);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.runTransaction((tx) async {
      final fresh = await tx.get(postRef);
      final data = fresh.data()! as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] ?? <String>[]);
      var count = (data['likeCount'] as int?) ?? 0;

      final isNowLiked = !likedBy.contains(user.uid);
      if (isNowLiked) {
        likedBy.add(user.uid);
        count++;
      } else {
        likedBy.remove(user.uid);
        count = count > 0 ? count - 1 : 0;
      }

      tx.update(postRef, {
        'likedBy': likedBy,
        'likeCount': count,
      });

      // after commit, notify author if it’s a new like
      if (isNowLiked) {
        final authorId = data['author'] as String?;
        if (authorId != null && authorId != user.uid) {
          await _notify.call({
            'targetUserId': authorId,
            'title': 'Your post was liked!',
            'body': 'Someone liked your post.',
          });
        }
      }
    });
  }
}
