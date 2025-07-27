// lib/screens/add_friend_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/friend_request.dart';
import '../services/friend_request_service.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _searchController = TextEditingController();
  final _service = FriendRequestService();

  late String _myUid;
  String _myName = '';
  String _myImageUrl = '';
  Set<String> _friendIds = {};
  Set<String> _pendingIds = {};
  List<UserResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser!.uid;
    _loadMyProfile();
    _loadFriendIds();
    _loadPendingIds();
  }

  Future<void> _loadMyProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_myUid)
        .get();
    final data = doc.data()!;
    setState(() {
      final first = data['firstName']?.toString() ?? '';
      final last  = data['surname']?.toString() ?? '';
      _myName     = '$first $last'.trim();
      _myImageUrl = data['imageUrl']?.toString() ?? '';
    });
  }

  Future<void> _loadFriendIds() async {
    final snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_myUid)
        .collection('friends')
        .get();
    setState(() {
      _friendIds = snap.docs.map((d) => d.id).toSet();
    });
  }

  Future<void> _loadPendingIds() async {
    final snap = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_myUid)
        .collection('sentRequests')
        .where('status', isEqualTo: 'pending')
        .get();
    setState(() {
      _pendingIds = snap.docs.map((d) => d.id).toSet();
    });
  }

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
        final last  = data['surname']?.toString() ?? '';
        return UserResult(
          id: doc.id,
          name: '$first $last'.trim(),
          imageUrl: data['imageUrl']?.toString() ?? '',
        );
      }).toList();

      setState(() => _results = results);
    } catch (e) {
      debugPrint('Search error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _sendRequest(UserResult user) async {
    final now = DateTime.now();

    final req = FriendRequest(
      id:        user.id,        // doc ID in their subcollection
      fromUid:   _myUid,
      fromName:  _myName,
      toUid:     user.id,
      toName:    user.name,
      imageUrl:  user.imageUrl,  // single field for the avatar
      created:   now,
      status:    'pending',
    );

    await _service.sendRequest(req);

    setState(() {
      _pendingIds.add(user.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request sent to ${user.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Add Friend',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              cursorColor: Colors.blue,
              onSubmitted: (_) => _doSearch(),
              decoration: InputDecoration(
                hintText: 'Search by email',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.blue),
                  onPressed: _doSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
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
            const SizedBox(height: 16),

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
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final user     = _results[i];
                    final isSelf    = user.id    == _myUid;
                    final isFriend  = _friendIds.contains(user.id);
                    final isPending = _pendingIds.contains(user.id);

                    Widget? button;
                    if (isSelf || isFriend) {
                      button = null;
                    } else if (isPending) {
                      button = OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    } else {
                      button = OutlinedButton(
                        onPressed: () => _sendRequest(user),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/fail.png',
                            image: user.imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            imageErrorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/fail.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style:
                        const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: button,
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

class UserResult {
  final String id;
  final String name;
  final String imageUrl;

  UserResult({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}
