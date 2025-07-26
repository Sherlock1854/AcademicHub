// lib/friend/models/friend_request.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  // Firestore document ID
  final String id;

  // Who sent the request
  final String fromUid;

  // Who should receive it
  final String toUid;

  // Display name of the target user
  final String name;

  // URL of the user’s avatar
  final String imageUrl;

  // When the request was created
  final DateTime created;

  // "pending", "accepted", or "declined"
  final String status;

  FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.name,
    required this.imageUrl,
    required this.created,
    required this.status,
  });

  /// Create from Firestore document
  factory FriendRequest.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id:        doc.id,
      fromUid:   data['fromUid']   as String,
      toUid:     data['toUid']     as String,
      name:      data['name']      as String,
      imageUrl:  data['imageUrl']  as String? ?? '',
      created:   (data['created'] as Timestamp).toDate(),
      status:    data['status']    as String,
    );
  }

  /// Convert to map for writing to Firestore
  Map<String, dynamic> toMap() => {
    'fromUid':  fromUid,
    'toUid':    toUid,
    'name':     name,
    'imageUrl': imageUrl,
    'created':  Timestamp.fromDate(created),
    'status':   status,
  };
}
