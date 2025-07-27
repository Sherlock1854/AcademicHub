// lib/friend/services/friend_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../chat/services/chat_service.dart';       // ← adjust path if needed
import '../models/friend.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _myUid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('Users').doc(_myUid).collection('friends');

  /// 1) Pinned first, then most recent.
  Stream<List<Friend>> friendsStream() {
    return _col
        .orderBy('pinned', descending: true)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => Friend.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> setFriend(Friend f) {
    return _col.doc(f.id).set(f.toMap());
  }

  /// Pin/unpin a friend
  Future<void> pinFriend(String friendId, bool pinned) {
    return _col.doc(friendId).set({'pinned': pinned}, SetOptions(merge: true));
  }

  /// Delete a friend on both sides and remove the conversation
  Future<void> deleteFriend(String friendId) async {
    final batch = _db.batch();

    // Remove friend record from current user
    final myFriendRef = _db
        .collection('Users')
        .doc(_myUid)
        .collection('friends')
        .doc(friendId);
    batch.delete(myFriendRef);

    // Remove reciprocal friend record
    final theirFriendRef = _db
        .collection('Users')
        .doc(friendId)
        .collection('friends')
        .doc(_myUid);
    batch.delete(theirFriendRef);

    // Commit both deletes together
    await batch.commit();

    // Delete the chat history (assumes ChatService.deleteConversation
    // handles removing all messages & conversation metadata for both sides)
    await ChatService().deleteConversation(friendId);
  }

  Future<void> markRead(String friendId) {
    return _col
        .doc(friendId)
        .set({'hasUnreadMessages': false}, SetOptions(merge: true));
  }
}
