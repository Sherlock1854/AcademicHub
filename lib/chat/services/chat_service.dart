// lib/services/chat_service.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static final HttpsCallable _sendPush = FirebaseFunctions.instance
      .httpsCallable('sendPushNotification');

  String get _myUid => FirebaseAuth.instance.currentUser!.uid;

  /// Helper to fetch the current user’s display name once per send
  String? _cachedMyName;

  Future<String> _fetchMyName() async {
    if (_cachedMyName != null) return _cachedMyName!;
    final meSnap = await _db.collection('Users').doc(_myUid).get();
    final data = meSnap.data()!;
    final first = data['firstName'] as String? ?? '';
    final last  = data['surname']   as String? ?? '';
    _cachedMyName = '$first $last'.trim();
    return _cachedMyName!;
  }


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
        .map(
          (snap) =>
              snap.docs
                  .where((d) {
                    final data = d.data();
                    return data['text'] != null || data['imageUrl'] != null;
                  })
                  .map((d) => ChatMessage.fromDoc(d))
                  .toList(),
        );
  }

  /// Upload image to Firebase Storage and return its URL
  Future<String> uploadImage(File file, String friendId) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('chat_images/$friendId/$fileName.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Send [text] or [imageUrl] to [friendId].
  Future<void> sendMessage({
    required String friendId,
    String? text,
    String? imageUrl,
  }) async {
    assert(text != null || imageUrl != null);

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

    final docRef = myCol.doc();
    final msgId = docRef.id;

    final dataForMe = {
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': now,
      'isSender': true,
      'seen': false,
    };
    final dataForThem = {
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': now,
      'isSender': false,
      'seen': false,
    };

    // write message copies
    await Future.wait([
      docRef.set(dataForMe),
      theirCol.doc(msgId).set(dataForThem),
    ]);

    // update conversation summaries
    final summaryForMe = {
      'lastText': text,
      'lastIsImage': imageUrl != null,
      'lastTimestamp': now,
      'lastIsSender': true,
      'hasUnreadMessages': false,
    };
    final summaryForThem = {
      'lastText': text,
      'lastIsImage': imageUrl != null,
      'lastTimestamp': now,
      'lastIsSender': false,
      'hasUnreadMessages': true,
    };
    await Future.wait([
      _db
          .collection('Users')
          .doc(_myUid)
          .collection('friends')
          .doc(friendId)
          .update(summaryForMe),
      _db
          .collection('Users')
          .doc(friendId)
          .collection('friends')
          .doc(_myUid)
          .update(summaryForThem),
    ]);

    // 3) Send a push ONLY to the one recipient, with your name in the body
    final myName = await _fetchMyName();

// This will check if `text` is non-null AND non-empty; otherwise it falls back.
    final body = (text?.isNotEmpty ?? false)
        ? '$myName: $text'
        : '$myName sent an image';

    await _sendPush.call({
      'targetUserId': friendId,
      'title': 'New message',
      'body': body,
    });
  }

  /// When *this* user views the chat, mark all incoming as seen
  /// and flip the sender’s copy to seen too.
  Future<void> markMessagesAsSeen(String friendId) async {
    final myMsgsRef = _db
        .collection('Users')
        .doc(_myUid)
        .collection('friends')
        .doc(friendId)
        .collection('messages');

    final snap =
        await myMsgsRef
            .where('isSender', isEqualTo: false)
            .where('seen', isEqualTo: false)
            .get();

    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (var doc in snap.docs) {
      // mark incoming as seen locally
      batch.update(doc.reference, {'seen': true});
      // mark sender’s copy as seen
      final theirDoc = _db
          .collection('Users')
          .doc(friendId)
          .collection('friends')
          .doc(_myUid)
          .collection('messages')
          .doc(doc.id);
      batch.update(theirDoc, {'seen': true});
    }
    await batch.commit();
  }

  /// Delete a single message on both sides
  Future<void> deleteMessage({
    required String friendId,
    required String messageId,
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

    return Future.wait([mine.delete(), theirs.delete()]);
  }

  /// Update only the text of a message on both sides
  Future<void> updateMessage({
    required String friendId,
    required String messageId,
    required String newText,
  }) {
    final data = {'text': newText, 'edited': true};

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

    return Future.wait([mine.update(data), theirs.update(data)]);
  }

  /// Update only the image URL of a message on both sides
  Future<void> updateMessageImage({
    required String friendId,
    required String messageId,
    required String newImageUrl,
  }) {
    final data = {'imageUrl': newImageUrl, 'edited': true};

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

    return Future.wait([mine.update(data), theirs.update(data)]);
  }

  /// Wipe out an entire conversation
  Future<void> deleteConversation(String friendId) async {
    final myMsgsRef = _db
        .collection('Users')
        .doc(_myUid)
        .collection('friends')
        .doc(friendId)
        .collection('messages');
    final theirMsgsRef = _db
        .collection('Users')
        .doc(friendId)
        .collection('friends')
        .doc(_myUid)
        .collection('messages');

    final batch = _db.batch();
    final mineSnap = await myMsgsRef.get();
    final theirSnap = await theirMsgsRef.get();

    for (var doc in mineSnap.docs) batch.delete(doc.reference);
    for (var doc in theirSnap.docs) batch.delete(doc.reference);

    await batch.commit();
  }
}
