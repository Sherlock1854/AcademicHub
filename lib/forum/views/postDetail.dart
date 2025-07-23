// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const SocialApp());
// }
//
// class SocialApp extends StatelessWidget {
//   const SocialApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Social Feed UI',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: const MainScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0; // 'Home' is selected by default
//
//   static const List<Widget> _widgetOptions = <Widget>[
//     FeedPage(), // Our main feed page
//     Center(child: Text('Courses Page')),
//     Center(child: Text('Quizzes Page')),
//     Center(child: Text('Forum Page')),
//     Center(child: Text('users Page')),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _widgetOptions.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Courses'),
//           BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Quizzes'),
//           BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'Forum'),
//           BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'users'),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         showUnselectedLabels: true,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }
//
// class FeedPage extends StatelessWidget {
//   const FeedPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.all(12.0),
//           children: const [
//             PostCard(),
//             // Add more PostCard widgets here for a full feed
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class PostCard extends StatelessWidget {
//   const PostCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       color: const Color(0xFFF0F4F8),
//       elevation: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Card Header
//             Row(
//               children: [
//                 const CircleAvatar(
//                   radius: 22,
//                   backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=41'),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       'Lysandra Quill',
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     Text(
//                       '2 hours ago',
//                       style: TextStyle(color: Colors.grey, fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             // Card Body
//             const Text(
//               'The beauty of New Zealand',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 'https://images.unsplash.com/photo-1507525428034-b723a996f3d4?q=80&w=2070', // Placeholder image
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'Exploring the beautiful landscapes of New Zealand!',
//               style: TextStyle(fontSize: 14),
//             ),
//             const SizedBox(height: 12),
//
//             // Action Stats
//             Row(
//               children: [
//                 const Icon(Icons.thumb_up, color: Colors.blue, size: 18),
//                 const SizedBox(width: 4),
//                 const Text('256', style: TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(width: 16),
//                 const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 18),
//                 const SizedBox(width: 4),
//                 const Text('34', style: TextStyle(fontWeight: FontWeight.bold)),
//                 const Spacer(),
//                 const Icon(Icons.more_horiz, color: Colors.grey),
//               ],
//             ),
//             const Divider(height: 24),
//
//             // Comment Section
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const CircleAvatar(
//                   radius: 18,
//                   backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=42'),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       RichText(
//                         text: const TextSpan(
//                           style: TextStyle(color: Colors.black, fontSize: 14),
//                           children: [
//                             TextSpan(
//                               text: 'Gideon Ashwood ',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             TextSpan(
//                                 text: 'This is such an inspiring post! Thanks for sharing.'),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey),
//                           const SizedBox(width: 16),
//                           const Icon(Icons.reply, size: 18, color: Colors.grey),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 const CircleAvatar(
//                   radius: 20,
//                   backgroundColor: Colors.blue,
//                   child: Icon(Icons.android, color: Colors.white, size: 24),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }