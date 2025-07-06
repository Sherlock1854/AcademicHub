// lib/friend/services/friend_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend.dart';

class FriendService {
  final _col = FirebaseFirestore.instance.collection('friends');

  /// Real-time stream of all friends
  Stream<List<Friend>> friendsStream() {
    return _col.snapshots().map((snap) => snap.docs
        .map((doc) => Friend.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Add or update a friend
  Future<void> setFriend(Friend f) {
    return _col.doc(f.id).set(f.toMap());
  }

  /// Remove a friend by ID
  Future<void> deleteFriend(String id) {
    return _col.doc(id).delete();
  }
}
