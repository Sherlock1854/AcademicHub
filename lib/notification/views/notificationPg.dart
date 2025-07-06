// import 'package:flutter/material.dart';
//
// // (Paste the NotificationItem class from above here)
// class NotificationItem {
//   final String title;
//   final String category;
//   final String description;
//   final String time;
//   bool isStarred;
//
//   NotificationItem({
//     required this.title,
//     required this.category,
//     required this.description,
//     required this.time,
//     this.isStarred = false,
//   });
// }
//
//
// void main() {
//   runApp(const NotificationsApp());
// }
//
// class NotificationsApp extends StatelessWidget {
//   const NotificationsApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Notifications UI',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: const NotificationsScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});
//
//   @override
//   _NotificationsScreenState createState() => _NotificationsScreenState();
// }
//
// class _NotificationsScreenState extends State<NotificationsScreen> {
//   final List<NotificationItem> _notifications = [
//     NotificationItem(
//       title: 'Tech Updates',
//       category: 'Weekly Newsletter',
//       description: 'Here are the top stories of the week...',
//       time: '5h ago',
//       isStarred: true,
//     ),
//     NotificationItem(
//       title: 'Your Bank',
//       category: 'Security Alert',
//       description: 'Suspicious activity detected...',
//       time: '2d ago',
//       isStarred: true,
//     ),
//     NotificationItem(
//       title: 'Account Services',
//       category: 'Password Change Confirmation',
//       description: 'Your password has been successfully cha...',
//       time: '4d ago',
//       isStarred: true,
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const Icon(Icons.arrow_back, color: Colors.black),
//         title: const Text(
//           'Notifications',
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         itemCount: _notifications.length,
//         itemBuilder: (context, index) {
//           final item = _notifications[index];
//           return ListTile(
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             title: Padding(
//               padding: const EdgeInsets.only(bottom: 4.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     item.title,
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   Text(
//                     item.time,
//                     style: const TextStyle(color: Colors.grey, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.category,
//                   style: TextStyle(color: Colors.grey[700], fontSize: 14),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         item.description,
//                         style: TextStyle(color: Colors.grey[600], fontSize: 13),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           item.isStarred = !item.isStarred;
//                         });
//                       },
//                       child: Icon(
//                         item.isStarred ? Icons.star : Icons.star_border,
//                         color: item.isStarred ? Colors.blue : Colors.grey,
//                         size: 20,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//             onTap: () {
//               // Handle notification tap
//             },
//           );
//         },
//       ),
//     );
//   }
// }