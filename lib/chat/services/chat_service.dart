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
        .collection('Users').doc(_myUid)
        .collection('friends').doc(friendId)
        .collection('messages');

    return col
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
    // map, filter out any docs without text or imageBase64
    snap.docs
        .map((d) => ChatMessage.fromDoc(d))
        .where((m) => m.text != null || m.imageBase64 != null)
        .toList()
    );
  }

  /// Send [text] or [imageBase64] to [friendId], using the same doc ID on both sides.
  Future<void> sendMessage({
    required String friendId,
    String? text,
    String? imageBase64,
  }) async {
    assert(
    text != null || imageBase64 != null,
    'Either text or imageBase64 must be provided',
    );

    final now = FieldValue.serverTimestamp();
    final myCol = _db
        .collection('Users').doc(_myUid)
        .collection('friends').doc(friendId)
        .collection('messages');
    final theirCol = _db
        .collection('Users').doc(friendId)
        .collection('friends').doc(_myUid)
        .collection('messages');

    // 1. Create a new doc ref (generates a shared ID)
    final docRef = myCol.doc();
    final msgId = docRef.id;

    // 2. Prepare payloads
    final dataForMe = {
      'text': text,
      'imageBase64': imageBase64,
      'timestamp': now,
      'isSender': true,
    };
    final dataForThem = {
      'text': text,
      'imageBase64': imageBase64,
      'timestamp': now,
      'isSender': false,
    };

    // 3. Write both with the same ID
    await Future.wait([
      docRef.set(dataForMe),
      theirCol.doc(msgId).set(dataForThem),
    ]);

    final summaryForMe = {
      'lastText': text,
      'lastIsImage': imageBase64 != null,
      'lastTimestamp': now,
      'lastIsSender': true,          // <–– you sent it
      'hasUnreadMessages': false,    // I just sent it, so I’ve “read” it
    };
    final summaryForThem = {
      'lastText': text,
      'lastIsImage': imageBase64 != null,
      'lastTimestamp': now,
      'lastIsSender': false,         // <–– they didn’t send it
      'hasUnreadMessages': true,     // they haven’t opened yet
    };

    await Future.wait([
      _db
          .collection('Users').doc(_myUid)
          .collection('friends').doc(friendId)
          .update(summaryForMe),
      _db
          .collection('Users').doc(friendId)
          .collection('friends').doc(_myUid)
          .update(summaryForThem),
    ]);
  }

  /// Delete the message with [messageId] in both users' subcollections.
  Future<void> deleteMessage({
    required String friendId,
    required String messageId,
  }) {
    final mine = _db
        .collection('Users').doc(_myUid)
        .collection('friends').doc(friendId)
        .collection('messages').doc(messageId);

    final theirs = _db
        .collection('Users').doc(friendId)
        .collection('friends').doc(_myUid)
        .collection('messages').doc(messageId);

    return Future.wait([mine.delete(), theirs.delete()]);
  }

  /// Update the text of the message in both users' subcollections.
  Future<void> updateMessage({
    required String friendId,
    required String messageId,
    required String newText,
  }) {
    final mine = _db
        .collection('Users').doc(_myUid)
        .collection('friends').doc(friendId)
        .collection('messages').doc(messageId);

    final theirs = _db
        .collection('Users').doc(friendId)
        .collection('friends').doc(_myUid)
        .collection('messages').doc(messageId);

    final data = {
      'text': newText,
      'edited': true,
    };

    return Future.wait([mine.update(data), theirs.update(data)]);
  }

  Future<void> updateMessageImage({
    required String friendId,
    required String messageId,
    required String newImageBase64,
  }) {
    final mine = _db
        .collection('Users')
        .doc(_myUid)
        .collection('friends')
        .doc(friendId)
        .collection('messages')
        .doc(messageId);

    final theirs = _db
        .collection('Users')
        .doc(friendId)
        .collection('friends')
        .doc(_myUid)
        .collection('messages')
        .doc(messageId);

    final data = {
      'imageBase64': newImageBase64,
      'edited': true,
    };
    return Future.wait([
      mine.update(data),
      theirs.update(data),
    ]);
  }

  /// Delete the entire conversation with [friendId] (all message docs
  /// under both users' subcollections).
  Future<void> deleteConversation(String friendId) async {
    // References to each side’s "messages" subcollection
    final myMsgsRef = _db
        .collection('Users').doc(_myUid)
        .collection('friends').doc(friendId)
        .collection('messages');
    final theirMsgsRef = _db
        .collection('Users').doc(friendId)
        .collection('friends').doc(_myUid)
        .collection('messages');

    // Batch‐delete for efficiency (Firestore limits 500 operations per batch).
    final batch = _db.batch();

    // Delete my side
    final mineSnap = await myMsgsRef.get();
    for (var doc in mineSnap.docs) {
      batch.delete(doc.reference);
    }

    // Delete their side
    final theirSnap = await theirMsgsRef.get();
    for (var doc in theirSnap.docs) {
      batch.delete(doc.reference);
    }

    // Commit all deletes at once
    await batch.commit();
  }
}
