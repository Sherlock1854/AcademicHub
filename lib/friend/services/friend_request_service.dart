// lib/friend/services/friend_request_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_request.dart';

class FriendRequestService {
  final _col = FirebaseFirestore.instance.collection('friend_requests');

  /// Stream of received friend requests
  Stream<List<FriendRequest>> receivedRequestsStream() {
    return _col
        .where('type', isEqualTo: 'received')   // if you store both types together
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => FriendRequest.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Stream of sent friend requests
  Stream<List<FriendRequest>> sentRequestsStream() {
    return _col
        .where('type', isEqualTo: 'sent')
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => FriendRequest.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Send a new friend request
  Future<void> sendRequest(FriendRequest req, {required bool received}) {
    final doc = _col.doc(req.id);
    return doc.set({
      ...req.toMap(),
      'type': received ? 'received' : 'sent',
    });
  }

  /// Cancel or decline a friend request
  Future<void> deleteRequest(String id) {
    return _col.doc(id).delete();
  }
}
