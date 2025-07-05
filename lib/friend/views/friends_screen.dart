import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../services/friend_service.dart';
import 'widgets/friend_list_item.dart';
import 'widgets/show_friend_requests_button.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final FriendService _service = FriendService();
  late Future<List<Friend>> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _service.fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button
          },
        ),
        title: const Text(
          'Friends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Friend>>(
        future: _friendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final friends = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (ctx, i) => FriendListItem(friend: friends[i]),
                ),
              ),
              const ShowFriendRequestsButton(),
            ],
          );
        },
      ),
    );
  }
}
