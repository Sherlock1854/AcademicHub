import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/settings.dart'; // <--- UPDATED IMPORT PATH
import '../services/settings_services.dart';
import '../views/widgets/settings_tile.dart';
import '../../bottom_nav.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  late List<SettingsItem> _generalSettings;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _generalSettings = _settingsService.getGeneralSettingsItems(onLogout: _signOut);
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      debugPrint('User signed out successfully!');
      if (mounted) {
        // Navigate to the login page and clear the navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'), // Added title for clarity
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            debugPrint('Back button tapped on Account Settings');
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              debugPrint('More options tapped on Account Settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[600],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Elowen Birch',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'elowan.birch@exa...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'General Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: _generalSettings.asMap().entries.map((entry) {
                  int index = entry.key;
                  SettingsItem item = entry.value;
                  return SettingsTile(
                    item: item,
                    showDivider: index < _generalSettings.length - 1,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20), // Added some bottom padding for scroll
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 4), // Added the bottom navigation bar
    );
  }
}

// Dummy classes for SettingsItem, SettingsService, SettingsTile (ensure these are correctly implemented in your project)
class SettingsItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isLogout;

  SettingsItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.isLogout = false,
  });
}

class SettingsService {
  List<SettingsItem> getGeneralSettingsItems({required VoidCallback onLogout}) {
    return [
      SettingsItem(title: 'Notifications', icon: Icons.notifications),
      SettingsItem(title: 'View Account Details', icon: Icons.account_box),
      SettingsItem(title: 'Privacy Settings', icon: Icons.lock),
      SettingsItem(title: 'Delete Account', icon: Icons.delete),
      SettingsItem(title: 'Logout', icon: Icons.logout, onTap: onLogout, isLogout: true),
    ];
  }
}

class SettingsTile extends StatelessWidget {
  final SettingsItem item;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.item,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(item.icon, color: Colors.blue),
          title: Text(item.title),
          trailing: item.onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
          onTap: item.onTap,
        ),
        if (showDivider)
          const Divider(
            indent: 16,
            endIndent: 16,
            height: 1,
          ),
      ],
    );
  }
}