import 'package:flutter/material.dart';
import '../models/settings.dart';
import 'package:academichub/auth/views/login.dart';  // <-- update this import path as needed

class SettingsService {
  List<SettingsItem> getGeneralSettingsItems({
    required BuildContext context,
    required VoidCallback onLogout,
  }) {
    return [
      SettingsItem(
        icon: Icons.notifications_none,
        title: 'Notifications',
        onTap: () {
          debugPrint('Notifications tapped');
        },
      ),
      SettingsItem(
        icon: Icons.article_outlined,
        title: 'View Account Details',
        onTap: () {
          debugPrint('View Account Details tapped');
        },
      ),
      SettingsItem(
        icon: Icons.lock_outline,
        title: 'Privacy Settings',
        onTap: () {
          debugPrint('Privacy Settings tapped');
        },
      ),
      SettingsItem(
        icon: Icons.person_remove_outlined,
        title: 'Delete Account',
        onTap: () {
          debugPrint('Delete Account tapped');
        },
        type: SettingsItemType.destructive,
      ),
      SettingsItem(
        icon: Icons.logout,
        title: 'Log Out',
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
          onLogout();
        },
        type: SettingsItemType.action,
      ),
    ];
  }
}
