// lib/models/forum_topic.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ForumTopic {
  final String id;
  final String title;
  final String? iconUrl;  // nullable

  ForumTopic({
    required this.id,
    required this.title,
    this.iconUrl,
  });

  factory ForumTopic.fromDoc(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return ForumTopic(
      id: doc.id,
      title: d['title'] as String,
      iconUrl: d['iconUrl'] as String?,  // newly stored field
    );
  }
}
