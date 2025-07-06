// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const FeedApp());
// }
//
// class FeedApp extends StatelessWidget {
//   const FeedApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Feed UI',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.white,
//         fontFamily: 'Roboto',
//       ),
//       home: const FeedScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// // Data models for a post
// class Post {
//   final String userName;
//   final String userImage;
//   final String time;
//   final String content;
//   final bool hasSpecialAction;
//
//   Post({
//     required this.userName,
//     required this.userImage,
//     required this.time,
//     required this.content,
//     this.hasSpecialAction = false,
//   });
// }
//
// class FeedScreen extends StatelessWidget {
//   const FeedScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Post> posts = [
//       Post(
//         userName: 'Amara C.',
//         userImage: 'https://i.pravatar.cc/150?img=31',
//         time: '2 hours ago',
//         content: 'Has anyone tried the new AI tool by OpenAI?',
//       ),
//       Post(
//         userName: 'Liam O.',
//         userImage: 'https://i.pravatar.cc/150?img=32',
//         time: '5 hours ago',
//         content: 'Looking for recommendations on the best JavaScript frameworks.',
//       ),
//       Post(
//         userName: 'Zara R.',
//         userImage: 'https://i.pravatar.cc/150?img=33',
//         time: '1 day ago',
//         content: 'How do you manage your time effectively while working remotely?',
//       ),
//       Post(
//         userName: 'Sophia L.',
//         userImage: 'https://i.pravatar.cc/150?img=34',
//         time: '4 days ago',
//         content: 'What are the latest trends in mobile app development?',
//         hasSpecialAction: true,
//       ),
//     ];
//
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             _SearchBar(),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: posts.length,
//                 separatorBuilder: (context, index) => const Divider(height: 1),
//                 itemBuilder: (context, index) {
//                   return _PostCard(post: posts[index]);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SearchBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: 'Search Posts',
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           filled: true,
//           fillColor: Colors.grey[200],
//           contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.0),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _PostCard extends StatelessWidget {
//   final Post post;
//
//   const _PostCard({required this.post});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(post.userImage),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     post.userName,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     post.time,
//                     style: const TextStyle(color: Colors.grey, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             post.content,
//             style: const TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               if (post.hasSpecialAction)
//                 const CircleAvatar(
//                   radius: 20,
//                   backgroundColor: Colors.blue,
//                   child: Icon(Icons.android, color: Colors.white, size: 24),
//                 )
//               else ...[
//                 IconButton(
//                   icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey),
//                   onPressed: () {},
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
//                   onPressed: () {},
//                 ),
//               ]
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }