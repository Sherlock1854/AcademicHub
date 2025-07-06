import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_topic.dart';
import '../models/forum_post.dart';

class ForumService {
  final _db = FirebaseFirestore.instance;

  /// Stream of all topics
  Stream<List<ForumTopic>> topics() {
    return _db.collection('topics')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ForumTopic.fromDoc(d)).toList());
  }

  /// Stream of posts under a topic
  Stream<List<ForumPost>> posts(String topicId) {
    return _db
        .collection('topics')
        .doc(topicId)
        .collection('posts')                // ← subcollection under the topic
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ForumPost.fromDoc(d))
        .toList());
  }

  Future<void> addTopic({
    required String title,
    required int iconCodePoint,
  }) {
    return _db.collection('topics').add({
      'title': title,
      'iconCodePoint': iconCodePoint,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addPost({
    required String topicId,
    required String author,
    required String title,
    required String body,
  }) {
    return _db
        .collection('topics')
        .doc(topicId)
        .collection('posts')
        .add({
      'author': author,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'topicId': topicId,
    });
  }
}

