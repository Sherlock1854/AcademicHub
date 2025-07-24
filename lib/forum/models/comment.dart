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

  /// Creates a Comment from a Firestore document snapshot,
  /// falling back to now() if the timestamp field is still null.
  factory Comment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['timestamp'] as Timestamp?;
    return Comment(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: ts?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this Comment to a map, for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'avatarUrl': avatarUrl,
      'text': text,
      // Use a client‐side timestamp to avoid null on reads
      'timestamp': Timestamp.now(),
    };
  }
}
