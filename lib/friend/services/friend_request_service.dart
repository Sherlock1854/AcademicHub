// lib/friend/services/friend_request_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_request.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FriendRequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final HttpsCallable _sendPush = FirebaseFunctions.instance
      .httpsCallable('sendPushNotification');
  late final String _myUid;
  // StreamSubscription<List<FriendRequest>>? _incomingSub;
  // final Set<String> _seenRequestIds = {};

  FriendRequestService() {
    _myUid = FirebaseAuth.instance.currentUser!.uid;
    // _incomingSub = receivedRequestsStream().listen(_handleIncoming);
  }

  // void dispose() {
  //   _incomingSub?.cancel();
  // }

  // Future<void> _handleIncoming(List<FriendRequest> requests) async {
  //   for (final req in requests) {
  //     if (!_seenRequestIds.contains(req.id)) {
  //       _seenRequestIds.add(req.id);
  //
  //       // fire-and-forget push
  //       await _sendPush.call({
  //         'targetUserId': _myUid,
  //         'title': 'New Friend Request',
  //         'body': '${req.name} sent you a request',
  //       });
  //     }
  //   }
  // }

  Stream<List<FriendRequest>> receivedRequestsStream() {
    return _db
        .collection('Users')
        .doc(_myUid)
        .collection('receivedRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('created', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => FriendRequest.fromDoc(doc)).toList(),
        );
  }

  Stream<List<FriendRequest>> sentRequestsStream() {
    return _db
        .collection('Users')
        .doc(_myUid)
        .collection('sentRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('created', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => FriendRequest.fromDoc(doc)).toList(),
        );
  }

  Future<void> sendRequest(FriendRequest req) async {
    final myUid = _myUid;
    final theirUid = req.toUid;

    // 1) Build an explicit map with both sides’ names:
    final data = <String, dynamic>{
      'fromUid': myUid,
      'fromName': req.fromName,    // <-- you’ll add this field to the model
      'toUid': theirUid,
      'toName': req.toName,        // <-- and this one too
      'imageUrl': req.imageUrl,
      'created': req.created,
      'status': 'pending',
    };

    // 2) Write into “sentRequests”
    await _db
        .collection('Users')
        .doc(myUid)
        .collection('sentRequests')
        .doc(theirUid)
        .set(data);

    // 3) Mirror into “receivedRequests”
    await _db
        .collection('Users')
        .doc(theirUid)
        .collection('receivedRequests')
        .doc(myUid)
        .set(data);

    // 4) Push notification as before
    await _sendPush.call({
      'targetUserId': theirUid,
      'title': 'New Friend Request',
      'body': '${req.fromName} sent you a request',
    });
  }

  Future<void> cancelRequest(String friendUid) {
    return Future.wait([
      _db
          .collection('Users')
          .doc(_myUid)
          .collection('sentRequests')
          .doc(friendUid)
          .update({'status': 'cancelled'}),
      _db
          .collection('Users')
          .doc(friendUid)
          .collection('receivedRequests')
          .doc(_myUid)
          .update({'status': 'cancelled'}),
    ]);
  }

  Future<void> declineRequest(String requesterUid) {
    return Future.wait([
      // Remove from my receivedRequests
      _db
          .collection('Users')
          .doc(_myUid)
          .collection('receivedRequests')
          .doc(requesterUid)
          .delete(),

      // Remove from their sentRequests
      _db
          .collection('Users')
          .doc(requesterUid)
          .collection('sentRequests')
          .doc(_myUid)
          .delete(),
    ]);
  }

  Future<void> acceptRequest(FriendRequest req) async {
    final myUid = _myUid;
    final otherUid = req.fromUid; // the sender

    // 1) Fetch _your_ profile so you can send *your* name/avatar back
    final meSnap = await _db.collection('Users').doc(myUid).get();
    final meData = meSnap.data()!;
    final myName = '${meData['firstName'] ?? ''} ${meData['surname'] ?? ''}'.trim();
    final myAvatar = meData['imageUrl'] as String? ?? '';

    // 2) Build the two friend‐records:

    // For current user (me), friend = the sender
    final friendForMe = {
      'name': req.fromName,      // show “acc 1”
      'avatarUrl': req.imageUrl, // their avatar
      // add any other Friend.toMap() fields like lastTimestamp, pinned...
      'lastText': '',
      'lastIsImage': false,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'lastIsSender': false,
      'hasUnreadMessages': false,
      'pinned': false,
    };

    // For the sender, friend = me
    final friendForThem = {
      'name': myName,            // show “acc 3” on their side
      'avatarUrl': myAvatar,     // your avatar
      'lastText': '',
      'lastIsImage': false,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'lastIsSender': false,
      'hasUnreadMessages': false,
      'pinned': false,
    };

    // 3) Write both records in a batch
    final batch = _db.batch();
    final meFriendRef   = _db.collection('Users').doc(myUid).collection('friends').doc(otherUid);
    final themFriendRef = _db.collection('Users').doc(otherUid).collection('friends').doc(myUid);

    batch.set(meFriendRef, friendForMe);
    batch.set(themFriendRef, friendForThem);

    // 4) Delete the pending request docs
    final meReqRef   = _db.collection('Users').doc(myUid).collection('receivedRequests').doc(otherUid);
    final themReqRef = _db.collection('Users').doc(otherUid).collection('sentRequests').doc(myUid);

    batch.delete(meReqRef);
    batch.delete(themReqRef);

    // 5) Commit
    await batch.commit();
  }
}
