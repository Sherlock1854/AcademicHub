// lib/friend/models/friend.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id;
  final String name;
  final String lastText;
  final bool lastIsImage;
  final DateTime? lastTimestamp;
  final bool lastIsSender;
  final String avatarBase64;
  final bool hasUnreadMessages;

  /// NEW:
  final bool pinned;

  Friend({
    required this.id,
    required this.name,
    required this.lastText,
    required this.lastIsImage,
    required this.lastTimestamp,
    required this.lastIsSender,
    required this.avatarBase64,
    this.hasUnreadMessages = false,
    this.pinned = false,           // ← default
  });

  factory Friend.fromMap(String id, Map<String, dynamic> data) {
    return Friend(
      id: id,
      name: data['name'] as String? ?? '',
      lastText: data['lastText'] as String? ?? '',
      lastIsImage: data['lastIsImage'] as bool? ?? false,
      lastTimestamp: (data['lastTimestamp'] as Timestamp?)?.toDate(),
      lastIsSender: data['lastIsSender'] as bool? ?? false,
      avatarBase64: data['avatarBase64'] as String? ?? '',
      hasUnreadMessages: data['hasUnreadMessages'] as bool? ?? false,
      pinned: data['pinned'] as bool? ?? false,  // ← read pinned
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'lastText': lastText,
    'lastIsImage': lastIsImage,
    'lastTimestamp': lastTimestamp != null
        ? Timestamp.fromDate(lastTimestamp!)
        : FieldValue.serverTimestamp(),
    'lastIsSender': lastIsSender,
    'avatarBase64': avatarBase64,
    'hasUnreadMessages': hasUnreadMessages,
    'pinned': pinned,                          // ← write pinned
  };
}
