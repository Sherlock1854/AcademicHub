import 'package:flutter/material.dart';

class FeedSearchBar extends StatelessWidget {
  const FeedSearchBar({super.key});
  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Posts',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
