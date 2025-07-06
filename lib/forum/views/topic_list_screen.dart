import 'package:flutter/material.dart';
import '../services/forum_service.dart';
import '../models/forum_topic.dart';
import 'post_list_screen.dart';

class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    return StreamBuilder<List<ForumTopic>>(
      stream: ForumService().topics(),
      builder: (c, s) {
        if (!s.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(
          children: s.data!.map((t) {
            return ListTile(
              leading: Icon(IconData(int.parse(t.iconName), fontFamily: 'MaterialIcons')),
              title: Text(t.title),
              onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                builder: (_) => PostListScreen(topic: t),
              )),
            );
          }).toList(),
        );
      },
    );
  }
}
