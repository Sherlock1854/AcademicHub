import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String topicId;
  final String author;        // userId
  final String title;
  final String body;
  final Timestamp timestamp;
  final String userImageUrl;
  final List<String> imageUrls;
  final int likeCount;        // total likes
  final int commentCount;     // total comments
  final List<String> likedBy; // ← NEW

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
    required this.likedBy,    // ← NEW
  });

  /// Create from Firestore doc
  factory ForumPost.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return ForumPost(
      id:           doc.id,
      topicId:      d['topicId']     as String,
      author:       d['author']      as String,
      title:        d['title']       as String,
      body:         d['body']        as String,
      timestamp:    d['timestamp']   as Timestamp,
      userImageUrl: d['userImageUrl'] as String? ?? '',
      imageUrls:    List<String>.from(d['imageUrls'] ?? []),
      likeCount:    d['likeCount']   as int?    ?? 0,
      commentCount: d['commentCount']as int?    ?? 0,
      likedBy:      List<String>.from(d['likedBy']   ?? []), // ← NEW
    );
  }

  /// Convert to map for saving
  Map<String, dynamic> toMap() => {
    'topicId':      topicId,
    'author':       author,
    'title':        title,
    'body':         body,
    'timestamp':    timestamp,
    'userImageUrl': userImageUrl,
    'imageUrls':    imageUrls,
    'likeCount':    likeCount,
    'commentCount': commentCount,
    'likedBy':      likedBy, // ← NEW
  };
}
