// lib/services/forum_service.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/forum_topic.dart';
import '../models/forum_post.dart';

class ForumService {
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// Stream of all topics
  Stream<List<ForumTopic>> topics() {
    return _db
        .collection('topics')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => ForumTopic.fromDoc(d)).toList());
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
        snap.docs.map((d) => ForumPost.fromDoc(d)).toList());
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
}
