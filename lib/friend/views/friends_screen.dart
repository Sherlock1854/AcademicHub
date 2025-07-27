// lib/screens/friends_screen.dart

import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../services/friend_service.dart';
import 'widgets/friend_list_item.dart';
import 'widgets/show_friend_requests_button.dart';
import 'add_friend_screen.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = FriendService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Friends',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
          final friends = snapshot.data ?? [];
          if (friends.isEmpty) {
            return const Center(
              child: Text(
                'You have no friends yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: friends.length,
            itemBuilder: (ctx, i) => FriendListItem(friend: friends[i]),
          );
        },
      ),

      // raise the button 16px above the nav‐bar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: const ShowFriendRequestsButton(),
        ),
      ),

      // FAB just above that (~64px up instead of 80px)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 2, right: 2),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(Icons.person_add, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddFriendScreen()),
            );
          },
        ),
      ),
    );
  }
}
