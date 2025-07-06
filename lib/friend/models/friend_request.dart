// lib/friend/models/friend_request.dart

class FriendRequest {
  final String id;    // ← Firestore document ID
  final String name;
  final String time;
  final String imageUrl;

  FriendRequest({
    required this.id,
    required this.name,
    required this.time,
    required this.imageUrl,
  });

  factory FriendRequest.fromMap(String id, Map<String, dynamic> data) {
    return FriendRequest(
      id: id,
      name: data['name'] as String,
      time: data['time'] as String,
      imageUrl: data['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'time': time,
    'imageUrl': imageUrl,
  };
}
