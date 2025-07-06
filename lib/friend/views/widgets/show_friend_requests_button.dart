// // lib/widgets/show_friend_requests_button.dart
//
// import 'package:flutter/material.dart';
// import '../friend_requests_screen.dart';
//
// class ShowFriendRequestsButton extends StatelessWidget {
//   const ShowFriendRequestsButton({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
//       child: OutlinedButton(
//         onPressed: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (_) => const FriendRequestsScreen(),
//             ),
//           );
//         },
//         style: OutlinedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 16.0),
//           side: BorderSide(color: Colors.grey.shade300),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//         ),
//         child: const Center(
//           child: Text(
//             'Show Friend Requests',
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
