import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/friend_request.dart';
import '../services/friend_request_service.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();
  final _service = FriendRequestService();
  List<UserResult> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _doSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _results = [];
    });

    try {
      final usersRef = FirebaseFirestore.instance.collection('Users');
      final snap = await usersRef
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      final results = snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final first = data['firstName']?.toString() ?? '';
        final last  = data['surname']?.toString()   ?? '';
        return UserResult(
          id: doc.id,
          name: '$first $last'.trim(),
          imageUrl: 'https://placehold.it/48',
        );
      }).toList();

      setState(() {
        _results = results;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e'))
      );
    } finally {
      // THIS is what actually stops the spinner
      setState(() {
        _isSearching = false;
      });
    }
  }

// imageUrl: data['imageUrl']?.toString()
//           ?? 'https://placehold.it/48',

  Future<void> _sendRequest(UserResult user) async {
    final req = FriendRequest(
      id: user.id,
      name: user.name,
      time: DateTime.now().toIso8601String(),
      imageUrl: user.imageUrl,
    );
    await _service.sendRequest(req);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request sent to ${user.name}')),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1) Search input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _doSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search by email',
                      filled: true,
                      fillColor: const Color(0xFFF7F7F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _doSearch,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2) Results or loading indicator
            if (_isSearching)
              const Center(child: CircularProgressIndicator())
            else if (_results.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
            // 3) List of found users
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final user = _results[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user.imageUrl),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: ElevatedButton(
                        onPressed: () => _sendRequest(user),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Simple models for a user search result (could reuse your Friend models if appropriate)
class UserResult {
  final String id;
  final String name;
  final String imageUrl;
  UserResult({required this.id, required this.name, required this.imageUrl});
}
