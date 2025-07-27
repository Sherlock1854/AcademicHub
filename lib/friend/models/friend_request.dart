// lib/friend/models/friend_request.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String id;         // doc.id
  final String fromUid;
  final String fromName;
  final String toUid;
  final String toName;
  final String imageUrl;
  final DateTime created;
  final String status;

  FriendRequest({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.imageUrl,
    required this.created,
    required this.status,
  });

  factory FriendRequest.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id: doc.id,
      fromUid: data['fromUid'] as String,
      fromName: data['fromName'] as String,
      toUid: data['toUid'] as String,
      toName: data['toName'] as String,
      imageUrl: data['imageUrl'] as String? ?? '',
      created: (data['created'] as Timestamp).toDate(),
      status: data['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() => {
    'fromUid': fromUid,
    'fromName': fromName,
    'toUid': toUid,
    'toName': toName,
    'imageUrl': imageUrl,
    'created': created,
    'status': status,
  };
}
