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
        .collection('posts')
        .where('topicId', isEqualTo: topicId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ForumPost.fromDoc(d)).toList());
  }
}
