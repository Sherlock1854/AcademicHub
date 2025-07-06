// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

/// A service for reading/writing chat messages in Firestore.
/// Each chat is stored under `chats/{chatId}/messages/{messageId}`.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a real-time stream of messages for the given chatId,
  /// ordered by timestamp ascending.
  Stream<List<ChatMessage>> messagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  /// Sends a text message. Either [text] or [imagePath] must be non-null.
  Future<void> sendMessage({
    required String chatId,
    String? text,
    String? imagePath,
  }) {
    assert(text != null || imagePath != null,
    'Either text or imagePath must be provided');
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text,
      'imagePath': imagePath,
      // Use serverTimestamp so ordering is reliable across devices
      'timestamp': FieldValue.serverTimestamp(),
      'isSender': true,
    });
  }

  /// Internal helper: converts a Firestore doc into a ChatMessage models.
  ChatMessage _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatMessage(
      text: data['text'] as String?,
      imagePath: data['imagePath'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      isSender: data['isSender'] as bool? ?? false,
    );
  }
}
