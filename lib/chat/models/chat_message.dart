import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String? text;
  final String? imageUrl; // <-- updated
  final DateTime timestamp;
  final bool isSender;
  final bool edited;
  final bool seen;

  ChatMessage({
    required this.id,
    this.text,
    this.imageUrl,
    this.edited = false,
    required this.timestamp,
    required this.isSender,
    this.seen = false,
  }) : assert(text != null || imageUrl != null, 'Either text or imageUrl must be non-null');

  factory ChatMessage.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatMessage(
      id: doc.id,
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?, // <-- updated
      edited: data['edited'] as bool? ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSender: data['isSender'] as bool? ?? false,
      seen: data['seen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'text': text,
    'imageUrl': imageUrl, // <-- updated
    'edited': edited,
    'timestamp': Timestamp.fromDate(timestamp),
    'isSender': isSender,
    'seen': seen,
  };
}

