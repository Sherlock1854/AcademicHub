import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import 'gemini_service.dart';

class BotChatService {
  final _db  = FirebaseFirestore.instance;
  final _api = GeminiApiService();
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('Users').doc(_uid).collection('chatbot');

  /// Stream all messages in the chatbot (oldest first).
  Stream<List<ChatMessage>> messagesStream() {
    return _col
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ChatMessage.fromDoc(d))
        .where((m) => m.text != null)
        .toList()
    );
  }

  /// Sends a user prompt, calls Gemini, saves both sides, returns the AI reply.
  Future<String> askAndSave(String prompt) async {
    final now = FieldValue.serverTimestamp();

    // 1️⃣ persist the user prompt
    await _col.add({
      'text': prompt,
      'timestamp': now,
      'isSender': true,
    });

    // 2️⃣ call Gemini
    final reply = await _api.askText(prompt);

    // 3️⃣ persist the bot reply
    await _col.add({
      'text': reply,
      'timestamp': now,
      'isSender': false,
    });

    return reply;
  }
}
