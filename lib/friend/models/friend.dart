// lib/friend/models/friend.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id;
  final String name;

  /// the text of the last message (empty if it was an image)
  final String lastText;
  /// true if the last message was an image
  final bool lastIsImage;
  /// when that last message was sent
  final DateTime? lastTimestamp;
  /// true if **you** sent the last message (so we prefix “You: ”)
  final bool lastIsSender;

  /// optional avatar stored as base64
  final String avatarBase64;

  /// unread‐dot
  final bool hasUnreadMessages;

  Friend({
    required this.id,
    required this.name,
    required this.lastText,
    required this.lastIsImage,
    required this.lastTimestamp,
    required this.lastIsSender,
    required this.avatarBase64,
    this.hasUnreadMessages = false,
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
  };
}
