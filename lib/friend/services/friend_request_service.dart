// lib/friend/services/friend_request_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_request.dart';

class FriendRequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _myUid => FirebaseAuth.instance.currentUser!.uid;

  /// Stream of requests **I** have received
  Stream<List<FriendRequest>> receivedRequestsStream() {
    return _db
        .collection('Users')
        .doc(_myUid)
        .collection('receivedRequests')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => FriendRequest.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Stream of requests **I** have sent
  Stream<List<FriendRequest>> sentRequestsStream() {
    return _db
        .collection('Users')
        .doc(_myUid)
        .collection('sentRequests')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => FriendRequest.fromMap(doc.id, doc.data()))
        .toList());
  }

  /// Send a friend request: write into both my `sentRequests` and
  /// their `receivedRequests` sub-collection
  Future<void> sendRequest(FriendRequest req) async {
    final theirUid = req.id;
    final myUid = _myUid;

    // 1) add under my sentRequests (doc ID = theirUid)
    await _db
        .collection('Users')
        .doc(myUid)
        .collection('sentRequests')
        .doc(theirUid)
        .set(req.toMap());

    // 2) add under their receivedRequests (doc ID = myUid)
    await _db
        .collection('Users')
        .doc(theirUid)
        .collection('receivedRequests')
        .doc(myUid)
        .set(req.toMap());
  }

  /// Cancel a sent request
  Future<void> cancelRequest(String friendUid) {
        final me = _myUid;
        return Future.wait([
          // remove from my sentRequests
          _db.collection('Users').doc(me)
             .collection('sentRequests').doc(friendUid)
             .delete(),
          // remove from their receivedRequests
          _db.collection('Users').doc(friendUid)
             .collection('receivedRequests').doc(me)
             .delete(),
        ]);
      }

  /// Decline/delete a received request
  Future<void> declineRequest(String requesterUid) {
        final me = _myUid;
        // remove from my receivedRequests *and* their sentRequests
        return Future.wait([
          _db
            .collection('Users').doc(me)
            .collection('receivedRequests').doc(requesterUid)
            .delete(),
          _db
            .collection('Users').doc(requesterUid)
            .collection('sentRequests').doc(me)
            .delete(),
        ]);
      }

    /// Accept a received request: add to both users' "friends" and clean up
    Future<void> acceptRequest(FriendRequest req) async {
        final me = _myUid;
        final other = req.id;

        // 1) add each other to friends
        await _db
          .collection('Users').doc(me)
          .collection('friends').doc(other)
          .set(req.toMap());
        await _db
          .collection('Users').doc(other)
          .collection('friends').doc(me)
          .set(req.toMap());

        // 2) delete original request from both subcollections
        await Future.wait([
          _db
            .collection('Users').doc(me)
            .collection('receivedRequests').doc(other)
            .delete(),
          _db
            .collection('Users').doc(other)
            .collection('sentRequests').doc(me)
            .delete(),
        ]);
      }
}
