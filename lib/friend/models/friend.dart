// lib/friend/models/friend.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String id;
  final String name;
  final String? lastText;
  final bool lastIsImage;
  final DateTime? lastTimestamp;
  final String avatarBase64;
  final bool hasUnreadMessages;

  Friend({
    required this.id,
    required this.name,
    this.lastText,
    this.lastIsImage = false,
    this.lastTimestamp,
    this.avatarBase64 = '',
    this.hasUnreadMessages = false,
  });

  factory Friend.fromMap(String id, Map<String, dynamic> data) {
    return Friend(
      id: id,
      name: data['name'] as String? ?? '',
      lastText: data['lastText'] as String?,
      lastIsImage: data['lastIsImage'] as bool? ?? false,
      lastTimestamp: (data['lastTimestamp'] as Timestamp?)?.toDate(),
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
        : null,
    'avatarBase64': avatarBase64,
    'hasUnreadMessages': hasUnreadMessages,
  };
}
