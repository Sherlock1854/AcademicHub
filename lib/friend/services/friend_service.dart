// lib/friend/services/friend_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend.dart';

class FriendService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _myUid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('Users').doc(_myUid).collection('friends');

  /// Real-time stream of **my** friends, sorted by lastTimestamp descending
  Stream<List<Friend>> friendsStream() {
    return _col
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => Friend.fromMap(doc.id, doc.data()))
        .toList()
    );
  }

  /// Add or update a friend under my subcollection
  Future<void> setFriend(Friend f) {
    return _col.doc(f.id).set(f.toMap());
  }

  /// Remove a friend by ID from **my** subcollection
  Future<void> deleteFriend(String id) {
    return _col.doc(id).delete();
  }

  /// Mark a conversation as read (clear the unread badge)
  Future<void> markRead(String friendId) {
    return _col
        .doc(friendId)
        .set({ 'hasUnreadMessages': false }, SetOptions(merge: true));
  }
}
