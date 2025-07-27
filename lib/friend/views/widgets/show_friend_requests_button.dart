// lib/widgets/show_friend_requests_button.dart

import 'package:flutter/material.dart';
import '../friend_requests_screen.dart';

class ShowFriendRequestsButton extends StatelessWidget {
  const ShowFriendRequestsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // fixed height
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const FriendRequestsScreen(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,                 // white bg
          side: BorderSide(color: Colors.grey.shade300), // light border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero, // no extra internal padding
        ),
        child: const Text(
          'Show Friend Requests',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
