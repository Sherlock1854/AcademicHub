import 'package:flutter/material.dart';
import '../services/forum_service.dart';
import '../models/forum_topic.dart';
import 'post_list_screen.dart';
import 'add_topic_dialog.dart';

class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborative forum'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<ForumTopic>>(
        stream: ForumService().topics(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final topics = snapshot.data!;
          if (topics.isEmpty) {
            return const Center(child: Text('No topics available'));
          }
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (ctx, i) {
              final t = topics[i];
              return ListTile(
                leading: Icon(t.icon, color: Colors.blue),
                title: Text(t.title),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PostListScreen(topic: t),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddTopicDialog(),
        ),
      ),
    );
  }
}
