import 'package:cloud_firestore/cloud_firestore.dart';

class ForumTopic {
  final String id;
  final String title;
  final String iconName; // store the icon key (e.g. 'sync')

  ForumTopic({required this.id, required this.title, required this.iconName});

  factory ForumTopic.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumTopic(
      id: doc.id,
      title: data['title'] as String,
      iconName: data['icon'] as String,
    );
  }
}
