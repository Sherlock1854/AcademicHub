// lib/screens/topic_list_screen.dart

import 'package:flutter/material.dart';
import '../../bottom_nav.dart';
import '../services/forum_service.dart';
import '../models/forum_topic.dart';
import 'post_list_screen.dart';
import 'add_topic_dialog.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({Key? key}) : super(key: key);

  @override
  _TopicListScreenState createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      body: Column(
        children: [
          // ──────────────────── Search bar ────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search topics…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),

          // ──────────────────── Topic list ────────────────────
          Expanded(
            child: StreamBuilder<List<ForumTopic>>(
              stream: ForumService().topics(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final allTopics = snap.data!;
                // apply filter
                final topics = _searchQuery.isEmpty
                    ? allTopics
                    : allTopics.where((t) =>
                    t.title.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (topics.isEmpty) {
                  return const Center(
                    child: Text(
                      'No topics found',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddTopicDialog(),
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 3), // Index 0 for Home
    );
  }
}
