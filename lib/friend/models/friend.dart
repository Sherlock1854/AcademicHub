// lib/friend/models/friend.dart

class Friend {
  final String id;                 // ← Firestore document ID
  final String name;
  final String lastMessage;
  final String time;
  final String imageUrl;
  final bool hasUnreadMessages;

  Friend({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    this.hasUnreadMessages = false,
  });

  factory Friend.fromMap(String id, Map<String, dynamic> data) {
    return Friend(
      id: id,
      name: data['name'] as String,
      lastMessage: data['lastMessage'] as String,
      time: data['time'] as String,
      imageUrl: data['imageUrl'] as String,
      hasUnreadMessages: data['hasUnreadMessages'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'lastMessage': lastMessage,
    'time': time,
    'imageUrl': imageUrl,
    'hasUnreadMessages': hasUnreadMessages,
  };
}
