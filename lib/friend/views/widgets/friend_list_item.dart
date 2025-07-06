// // lib/widgets/friend_list_item.dart
//
// import 'package:flutter/material.dart';
// import '../../../chat/views/chat_screen.dart';
// import '../../models/friend.dart';
//
// class FriendListItem extends StatelessWidget {
//   final Friend friend;
//   const FriendListItem({required this.friend, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: CircleAvatar(
//         radius: 28,
//         backgroundImage: NetworkImage(friend.imageUrl),
//       ),
//       title: Text(
//         friend.name,
//         style: const TextStyle(fontWeight: FontWeight.bold),
//       ),
//       subtitle: Text(
//         friend.lastMessage,
//         style: const TextStyle(color: Colors.grey),
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//       trailing: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(friend.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           const SizedBox(height: 4),
//           if (friend.hasUnreadMessages)
//             const CircleAvatar(radius: 4, backgroundColor: Colors.blue),
//         ],
//       ),
//       onTap: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (_) => ChatScreen(friend: friend),
//           ),
//         );
//       },
//     );
//   }
// }
