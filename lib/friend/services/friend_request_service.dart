import '../models/friend_request.dart';

class FriendRequestService {
  /// Simulates fetching received friend requests.
  Future<List<FriendRequest>> fetchReceivedRequests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      FriendRequest(
        name: 'Aurelia Monroe',
        time: '10:00 AM',
        imageUrl: 'https://i.pravatar.cc/150?img=11',
      ),
      FriendRequest(
        name: 'Balthazar Trent',
        time: '9:30 AM',
        imageUrl: 'https://i.pravatar.cc/150?img=12',
      ),
      FriendRequest(
        name: 'Callista Vega',
        time: 'Yesterday',
        imageUrl: 'https://i.pravatar.cc/150?img=13',
      ),
      FriendRequest(
        name: 'Desmond Hale',
        time: '2 days ago',
        imageUrl: 'https://i.pravatar.cc/150?img=14',
      ),
      FriendRequest(
        name: 'Evelyn Frost',
        time: '3 days ago',
        imageUrl: 'https://i.pravatar.cc/150?img=15',
      ),
      FriendRequest(
        name: 'Giselle Hart',
        time: 'Last month',
        imageUrl: 'https://i.pravatar.cc/150?img=16',
      ),
    ];
  }

  /// Simulates fetching sent friend requests.
  Future<List<FriendRequest>> fetchSentRequests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return empty to match the “No sent requests” placeholder
    return [];
  }
}
