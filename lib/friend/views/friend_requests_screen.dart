// import 'package:flutter/material.dart';
// import '../models/friend_request.dart';
// import '../services/friend_request_service.dart';
// import 'widgets/friend_request_item.dart';
//
// class FriendRequestsScreen extends StatefulWidget {
//   const FriendRequestsScreen({super.key});
//
//   @override
//   State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
// }
//
// class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
//   final service = FriendRequestService();
//   late Future<List<FriendRequest>> _receivedFuture;
//   late Future<List<FriendRequest>> _sentFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _receivedFuture = service.fetchReceivedRequests();
//     _sentFuture = service.fetchSentRequests();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () {},
//           ),
//           title: const Text(
//             'Friend Requests',
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//           ),
//           centerTitle: true,
//           bottom: const TabBar(
//             indicatorColor: Colors.blue,
//             labelColor: Colors.blue,
//             unselectedLabelColor: Colors.grey,
//             tabs: [
//               Tab(text: 'Received'),
//               Tab(text: 'Sent'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             // Received
//             FutureBuilder<List<FriendRequest>>(
//               future: _receivedFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState != ConnectionState.done) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 final requests = snapshot.data!;
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   itemCount: requests.length,
//                   itemBuilder: (ctx, i) =>
//                       FriendRequestItem(request: requests[i]),
//                 );
//               },
//             ),
//
//             // Sent
//             FutureBuilder<List<FriendRequest>>(
//               future: _sentFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState != ConnectionState.done) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 final requests = snapshot.data!;
//                 if (requests.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No sent requests',
//                       style: TextStyle(color: Colors.grey, fontSize: 16),
//                     ),
//                   );
//                 }
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   itemCount: requests.length,
//                   itemBuilder: (ctx, i) =>
//                       FriendRequestItem(request: requests[i]),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
