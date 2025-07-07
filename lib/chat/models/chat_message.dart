// lib/models/chat_message.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String? text;
  final String? imageUrl;    // renamed from imagePath
  final DateTime timestamp;
  final bool isSender;

  ChatMessage({
    this.text,
    this.imageUrl,
    required this.timestamp,
    required this.isSender,
  }) : assert(text != null || imageUrl != null,
  'Either text or imageUrl must be non-null');

  /// Factory to build from a Firestore doc snapshot
  factory ChatMessage.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatMessage(
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate()
          ?? DateTime.now(),
      isSender: data['isSender'] as bool? ?? false,
    );
  }

  /// If you ever need a toMap (e.g. for local caching), you can add:
  Map<String, dynamic> toMap() => {
    'text': text,
    'imageUrl': imageUrl,
    'timestamp': Timestamp.fromDate(timestamp),
    'isSender': isSender,
  };
}
