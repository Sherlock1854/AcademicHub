// lib/models/forum_topic.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ← add this

class ForumTopic {
  final String id;
  final String title;
  final IconData icon;                // now a real IconData

  ForumTopic({
    required this.id,
    required this.title,
    required this.icon,
  });

  /// If you’re loading from Firestore:
  factory ForumTopic.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return ForumTopic(
      id: doc.id,
      title: d['title'] as String,
      icon: IconData(
        d['iconCodePoint'] as int,
        fontFamily: 'MaterialIcons',
      ),
    );
  }
}
