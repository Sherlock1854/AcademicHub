// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _myUid => FirebaseAuth.instance.currentUser!.uid;

  /// Stream of messages exchanged with [friendId], oldest first.
  Stream<List<ChatMessage>> messagesStream(String friendId) {
    final col = _db
        .collection('Users')
        .doc(_myUid)
        .collection('friends')
        .doc(friendId)
        .collection('messages');

    return col
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  /// Send [text] or [imageUrl] to [friendId].
  /// Duplicates it into both users' message subcollections.
  Future<void> sendMessage({
    required String friendId,
    String? text,
    String? imageUrl,
  }) async {
    assert(text != null || imageUrl != null,
    'Either text or imageUrl must be provided');

    final now = FieldValue.serverTimestamp();
    final myCol = _db
        .collection('Users')
        .doc(_myUid)
        .collection('friends')
        .doc(friendId)
        .collection('messages');
    final theirCol = _db
        .collection('Users')
        .doc(friendId)
        .collection('friends')
        .doc(_myUid)
        .collection('messages');

    final dataForMe = {
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': now,
      'isSender': true,
    };
    final dataForThem = {
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': now,
      'isSender': false,
    };

    // write both docs in parallel
    await Future.wait([
      myCol.add(dataForMe),
      theirCol.add(dataForThem),
    ]);
  }

  ChatMessage _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatMessage(
      text: data['text'] as String?,
      imageUrl: data['imageUrl'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSender: data['isSender'] as bool? ?? false,
    );
  }
}
