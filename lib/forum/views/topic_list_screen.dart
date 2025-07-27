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
  String _searchInput = '';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    setState(() {
      _searchQuery = _searchInput.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 1,
        centerTitle: true,
        foregroundColor: Colors.black,
        title: const Text(
          'Collaborative forum',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.blue,
              textInputAction: TextInputAction.search,
              onChanged: (val) => _searchInput = val,
              onSubmitted: (_) => _applySearch(),
              decoration: InputDecoration(
                hintText: 'Search topics…',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: _applySearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),
          // ── Topic List ─────────────────────────────────────────
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
                final topics = _searchQuery.isEmpty
                    ? allTopics
                    : allTopics
                    .where((t) => t.title
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                    .toList();

                if (topics.isEmpty) {
                  return const Center(
                    child: Text(
                      'No topics found',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: topics.length,
                  itemBuilder: (ctx, i) {
                    final t = topics[i];
                    return ListTile(
                      leading: ClipOval(
                        child: t.iconUrl != null
                            ? Image.network(
                          t.iconUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/fail.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Image.asset(
                          'assets/images/fail.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(t.title),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => PostListScreen(topic: t)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.blue),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddTopicDialog(),
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(
        selectedIndex: 3,
        isAdmin: true, // ← explicitly passing isAdmin: true
      ),
    );
  }
}
