import '../models/friend.dart';

class FriendService {
  /// Simulates fetching friend data from an API or database.
  Future<List<Friend>> fetchFriends() async {
    // In a real app you'd make an HTTP call here.
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      Friend(
        name: 'Lysandra Elwyn',
        lastMessage: 'Hey, are we still on for tonight?',
        time: '10:30 AM',
        imageUrl: 'https://i.pravatar.cc/150?img=1',
        hasUnreadMessages: true,
      ),
      Friend(
        name: 'Thorne Evernight',
        lastMessage: 'Check out this new place I found!',
        time: '9:15 AM',
        imageUrl: 'https://i.pravatar.cc/150?img=2',
      ),
      // ... other friends
    ];
  }
}
