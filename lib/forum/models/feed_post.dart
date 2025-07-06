import 'package:cloud_firestore/cloud_firestore.dart';

class FeedPost {
  final String id;
  final String userName;
  final String userImage;
  final Timestamp timestamp;
  final String content;
  final bool hasSpecialAction;

  FeedPost({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.timestamp,
    required this.content,
    this.hasSpecialAction = false,
  });

  factory FeedPost.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FeedPost(
      id: doc.id,
      userName: d['userName'] as String,
      userImage: d['userImage'] as String,
      timestamp: d['timestamp'] as Timestamp,
      content: d['content'] as String,
      hasSpecialAction: d['hasSpecialAction'] as bool? ?? false,
    );
  }
}
