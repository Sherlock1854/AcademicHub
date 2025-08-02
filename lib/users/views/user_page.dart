// lib/users/views/user_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:academichub/bottom_nav.dart';
import 'package:academichub/users/services/user_services.dart';
import 'package:academichub/users/models/user_settings.dart';
import 'widgets/user_tile.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final _settingsService = UserSettingsService();
  late final List<UserSettingsItem> _userSettings;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _userSettings = _settingsService.getUserSettingsItems(
      context: context,
      onLogout: () => _settingsService.signOut(context),
      onDelete: () => _settingsService.deleteAccount(context),
      onEditComplete: _loadUserData,
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _settingsService.fetchUserData();
    if (mounted) setState(() => _userData = data);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Fetch firstName and surname, defaulting to empty strings if not present
    final firstName = _userData?['firstName'] ?? '';
    final surname = _userData?['surname'] ?? '';
    final displayName = (firstName.isNotEmpty || surname.isNotEmpty)
        ? '$firstName $surname'.trim()
        : 'Loading...';

    final email = user?.email ?? 'email@example.com';
    final role = _userData?['role'] as String?;
    final photoUrl = _userData?['photoUrl'] as String?;
    final about = _userData?['about'] as String?;

    final formattedRole = role != null
        ? '${role[0].toUpperCase()}${role.substring(1)}'
        : null;

    // Only 'admin' uses the 4-slot nav; regular users use the 5-slot nav
    final isAdmin = role == 'admin';
    final selectedIndex = isAdmin ? 3 : 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold, // ← bold title text
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Profile Section
            CircleAvatar(
              key: ValueKey(photoUrl),
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage:
              photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? const Icon(
                Icons.person,
                size: 50,
                color: Colors.white70,
              )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
            if (about != null && about.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'About Me',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    about,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Settings List
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: _userSettings.map((item) {
                  return UserSettingsTile(
                    item: item,
                    showDivider: item != _userSettings.last,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: selectedIndex,
        isAdmin: isAdmin,
      ),
    );
  }
}
