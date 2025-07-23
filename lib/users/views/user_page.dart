import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../bottom_nav.dart';
import '../models/user_settings.dart';
import '../services/user_services.dart';
import 'widgets/user_tile.dart';
import '../../auth/views/login.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserSettingsService _settingsService = UserSettingsService();

  late List<UserSettingsItem> _userSettings;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _userSettings = _settingsService.getUserSettingsItems(
      context: context,
      onLogout: _signOut,
      onDelete: _deleteAccount,
    );
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final user = _auth.currentUser;
      final uid = user?.uid;

      if (uid != null) {
        await FirebaseFirestore.instance.collection('Users').doc(uid).delete();
        await user!.delete();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Account deletion failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deletion failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileSection(user),
            const SizedBox(height: 20),
            _buildSettingsList(),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 4),
    );
  }

  Widget _buildProfileSection(User? user) {
    final fullName = _userData != null
        ? '${_userData!['firstName']} ${_userData!['surname']}'
        : 'Loading...';

    final email = user?.email ?? 'email@example.com';
    final role = _userData?['role'];
    final formattedRole = role != null
        ? role.toString()[0].toUpperCase() + role.toString().substring(1)
        : null;

    // ✅ Default image fallback
    const defaultImageUrl =
        'https://firebasestorage.googleapis.com/v0/b/academichub-c1068.appspot.com/o/profile%2Fdefault_user.png?alt=media';



    // ✅ If `photoUrl` field exists in Firestore, use it
    final photoUrl = _userData?['photoUrl'] ?? defaultImageUrl;

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          backgroundImage: NetworkImage(photoUrl ?? defaultImageUrl),
        ),
        const SizedBox(height: 12),
        Text(
          fullName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(color: Colors.grey[600]),
        ),
        if (formattedRole != null) ...[
          const SizedBox(height: 2),
          Text(
            formattedRole,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsList() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: _userSettings.asMap().entries.map((entry) {
          return UserSettingsTile(
            item: entry.value,
            showDivider: entry.key < _userSettings.length - 1,
          );
        }).toList(),
      ),
    );
  }
}
