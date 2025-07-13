// lib/models/chat_message.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String? text;
  final String? imageBase64;
  final DateTime timestamp;
  final bool isSender;
  final bool edited;

  ChatMessage({
  required this.id,
  this.text,
  this.imageBase64,
  this.edited = false,
  required this.timestamp,
  required this.isSender,
}) : assert(text != null || imageBase64 != null,
'Either text or imageBase64 must be non-null');

factory ChatMessage.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
final data = doc.data();
return ChatMessage(
id: doc.id,
text: data['text'] as String?,
imageBase64: data['imageBase64'] as String?,
edited: data['edited'] as bool? ?? false,
timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
isSender: data['isSender'] as bool? ?? false,
);
}

Map<String, dynamic> toMap() => {
'text': text,
'imageBase64': imageBase64,
'edited': edited,
'timestamp': Timestamp.fromDate(timestamp),
'isSender': isSender,
};
}
