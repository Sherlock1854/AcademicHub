import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String topicId;
  final String author; // This will store the user ID, not full name
  final String title;
  final String body;
  final Timestamp timestamp;
  final String userImageUrl;
  final List<String> imageUrls; // New: for attached images

  ForumPost({
    required this.id,
    required this.topicId,
    required this.author,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.userImageUrl,
    required this.imageUrls,
  });

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
      imageUrls: List<String>.from(d['imageUrls'] ?? []), // fallback to empty list
    );
  }

  Map<String, dynamic> toMap() => {
    'topicId': topicId,
    'author': author,
    'title': title,
    'body': body,
    'timestamp': timestamp,
    'userImageUrl': userImageUrl,
    'imageUrls': imageUrls,
  };
}
