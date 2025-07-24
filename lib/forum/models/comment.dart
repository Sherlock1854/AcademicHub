// lib/models/comment.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String authorName;
  final String avatarUrl;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.authorName,
    required this.avatarUrl,
    required this.text,
    required this.timestamp,
  });

  /// Creates a Comment from a Firestore document snapshot
  factory Comment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      authorName: data['authorName'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Converts this Comment to a map, for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'authorName': authorName,
      'avatarUrl': avatarUrl,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
