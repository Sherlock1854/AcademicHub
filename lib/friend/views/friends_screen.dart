// lib/screens/friends_screen.dart

import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../services/friend_service.dart';
import 'widgets/friend_list_item.dart';
import 'widgets/show_friend_requests_button.dart';
import 'add_friend_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FriendService();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Friends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Friend>>(
        stream: service.friendsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final friends = snapshot.data!;
          // Wrap in Column so we can put the button below
          return Column(
            children: [
              Expanded(
                child: friends.isEmpty
                    ? const Center(
                  child: Text(
                    'You have no friends yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: friends.length,
                  itemBuilder: (ctx, i) =>
                      FriendListItem(friend: friends[i]),
                ),
              ),

              // ← Here's your missing button
              const ShowFriendRequestsButton(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () {
          // Navigate to your “Search/Add Friend” screen
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddFriendScreen(),
          ));
        },
      ),
    );
  }
}
