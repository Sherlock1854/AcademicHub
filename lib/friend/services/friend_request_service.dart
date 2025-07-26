// lib/friend/services/friend_request_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/friend_request.dart';
import '../../notification/services/notification_service.dart';
import '../../notification/models/notification_item.dart';

class FriendRequestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notifier = NotificationService();
  late final String _myUid;
  StreamSubscription<List<FriendRequest>>? _incomingSub;
  final Set<String> _seenRequestIds = {};

  FriendRequestService() {
    _myUid = FirebaseAuth.instance.currentUser!.uid;
    _incomingSub = receivedRequestsStream().listen(_handleIncoming);
  }

  void dispose() {
    _incomingSub?.cancel();
  }

  Future<void> _handleIncoming(List<FriendRequest> requests) async {
    for (final req in requests) {
      if (!_seenRequestIds.contains(req.id)) {
        _seenRequestIds.add(req.id);

        // Build a NotificationItem with the required fields:
        final note = NotificationItem(
          id:         req.id,
          title:      'New Friend Request',
          description:'${req.name} sent you a request',
          category:   'friend_request',    // your chosen category
          fromUserId: req.fromUid,         // who sent it
          timestamp:  DateTime.now(),      // DateTime, not String
          status:     'unread',            // mark unread
        );

        // Save + push
        await _notifier.sendNotification(
          toUserId: _myUid,
          item:     note,
        );
      }
    }
  }

  Stream<List<FriendRequest>> receivedRequestsStream() {
    return _db
        .collection('Users')
        .doc(_myUid)
        .collection('receivedRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('created', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => FriendRequest.fromDoc(doc)).toList());
  }

  Stream<List<FriendRequest>> sentRequestsStream() {
    return _db
        .collection('Users')
        .doc(_myUid)
        .collection('sentRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('created', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => FriendRequest.fromDoc(doc)).toList());
  }

  Future<void> sendRequest(FriendRequest req) async {
    final theirUid = req.toUid;
    final data = req.toMap();

    await _db
        .collection('Users')
        .doc(_myUid)
        .collection('sentRequests')
        .doc(theirUid)
        .set(data);

    await _db
        .collection('Users')
        .doc(theirUid)
        .collection('receivedRequests')
        .doc(_myUid)
        .set(data);
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
      _db
          .collection('Users')
          .doc(_myUid)
          .collection('receivedRequests')
          .doc(requesterUid)
          .update({'status': 'declined'}),
      _db
          .collection('Users')
          .doc(requesterUid)
          .collection('sentRequests')
          .doc(_myUid)
          .update({'status': 'declined'}),
    ]);
  }

  Future<void> acceptRequest(FriendRequest req) async {
    final other = req.fromUid;
    final friendData = {
      'name':    req.name,
      'addedAt': req.created.toIso8601String(),
    };

    await _db
        .collection('Users')
        .doc(_myUid)
        .collection('friends')
        .doc(other)
        .set(friendData);
    await _db
        .collection('Users')
        .doc(other)
        .collection('friends')
        .doc(_myUid)
        .set(friendData);

    await Future.wait([
      _db
          .collection('Users')
          .doc(_myUid)
          .collection('receivedRequests')
          .doc(other)
          .delete(),
      _db
          .collection('Users')
          .doc(other)
          .collection('sentRequests')
          .doc(_myUid)
          .delete(),
    ]);
  }
}
