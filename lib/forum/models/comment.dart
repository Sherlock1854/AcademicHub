// lib/models/comment.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String authorId;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.authorId,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
  });

  /// Creates a Comment from a Firestore document snapshot
  factory Comment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Comment(
      id:        doc.id,
      authorId:  data['authorId']  as String?   ?? '',
      avatarUrl: data['avatarUrl'] as String?   ?? '',
      text:      data['text']      as String?   ?? '',
      timestamp: (data['timestamp'] as Timestamp?)
          ?.toDate()    ?? DateTime.now(),
    );
  }
}
