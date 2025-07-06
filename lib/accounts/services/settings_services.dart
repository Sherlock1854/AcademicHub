import 'package:flutter/material.dart';
import '../models/settings.dart'; // <--- UPDATED IMPORT PATH

class SettingsService {
  List<SettingsItem> getGeneralSettingsItems({required VoidCallback onLogout}) {
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
        onTap: onLogout,
        type: SettingsItemType.action,
      ),
    ];
  }
}