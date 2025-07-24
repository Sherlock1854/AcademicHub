// import 'package:flutter/material.dart';
// import '../../models/feed_post.dart';
// import 'package:intl/intl.dart';
//
// class PostCard extends StatelessWidget {
//   final FeedPost post;
//   const PostCard({required this.post, super.key});
//
//   String _timeAgo(DateTime t) {
//     final diff = DateTime.now().difference(t);
//     if (diff.inDays > 1) return '${diff.inDays}d ago';
//     if (diff.inHours > 1) return '${diff.inHours}h ago';
//     return '${diff.inMinutes}m ago';
//   }
//
//   @override
//   Widget build(BuildContext ctx) {
//     final dt = post.timestamp.toDate();
//     return Card(
//       margin: const EdgeInsets.all(12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             CircleAvatar(backgroundImage: NetworkImage(post.userImage)),
//             const SizedBox(width: 8),
//             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
//               Text(_timeAgo(dt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
//             ])
//           ]),
//           const SizedBox(height: 12),
//           Text(post.content),
//           const SizedBox(height: 12),
//           Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//             if (post.hasSpecialAction)
//               const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.android, color: Colors.white))
//             else ...[
//               IconButton(icon: const Icon(Icons.thumb_up_alt_outlined), onPressed: () {}),
//               IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
//             ]
//           ])
//         ]),
//       ),
//     );
//   }
// }
