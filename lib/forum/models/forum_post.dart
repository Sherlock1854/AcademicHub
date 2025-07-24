// lib/models/forum_post.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String topicId;
  final String author;        // this is the userId of the post author
  final String title;
  final String body;
  final Timestamp timestamp;
  final String userImageUrl;
  final List<String> imageUrls;
  final int likeCount;        // new: total likes
  final int commentCount;     // new: cached total comments

  ForumPost({
    required this.id,
    required this.topicId,
    required this.author,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.userImageUrl,
    required this.imageUrls,
    required this.likeCount,
    required this.commentCount,
  });

  /// Creates a ForumPost from a Firestore document snapshot
  factory ForumPost.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return ForumPost(
      id: doc.id,
      topicId: d['topicId'] as String,
      author: d['author'] as String,
      title: d['title'] as String,
      body: d['body'] as String,
      timestamp: d['timestamp'] as Timestamp,
      userImageUrl: d['userImageUrl'] as String? ?? '',
      imageUrls: List<String>.from(d['imageUrls'] ?? []),
      likeCount: d['likeCount'] as int? ?? 0,
      commentCount: d['commentCount'] as int? ?? 0,
    );
  }

  /// Converts this ForumPost to a map, for saving to Firestore
  Map<String, dynamic> toMap() => {
    'topicId': topicId,
    'author': author,
    'title': title,
    'body': body,
    'timestamp': timestamp,
    'userImageUrl': userImageUrl,
    'imageUrls': imageUrls,
    'likeCount': likeCount,
    'commentCount': commentCount,
  };
}
