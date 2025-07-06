import 'package:flutter/material.dart';
import '../models/friend_request.dart';
import '../services/friend_request_service.dart';
import 'widgets/friend_request_item.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FriendRequestService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Friend Requests',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Received
            StreamBuilder<List<FriendRequest>>(
              stream: service.receivedRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final requests = snapshot.data!;
                if (requests.isEmpty) {
                  return const Center(
                    child: Text(
                      'No received requests',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (ctx, i) =>
                      FriendRequestItem(request: requests[i]),
                );
              },
            ),

            // Sent
            StreamBuilder<List<FriendRequest>>(
              stream: service.sentRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final requests = snapshot.data!;
                if (requests.isEmpty) {
                  return const Center(
                    child: Text(
                      'No sent requests',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (ctx, i) =>
                      FriendRequestItem(request: requests[i], isSent: true,),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
