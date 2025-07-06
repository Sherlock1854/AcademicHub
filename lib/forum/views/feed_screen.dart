import 'package:flutter/material.dart';
import '../services/feed_service.dart';
import '../models/feed_post.dart';
import 'widgets/feed_search_bar.dart';
import 'widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  @override
  Widget build(BuildContext ctx) {
    return SafeArea(
      child: Column(
        children: [
          const FeedSearchBar(),
          Expanded(
            child: StreamBuilder<List<FeedPost>>(
              stream: FeedService().feed(),
              builder: (c, s) {
                if (!s.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.separated(
                  itemCount: s.data!.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => PostCard(post: s.data![i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
