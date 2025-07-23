import 'package:flutter/material.dart';
import 'package:academichub/auth/views/login.dart';
import '../models/user_settings.dart';

class UserSettingsService {
  List<UserSettingsItem> getUserSettingsItems({
    required BuildContext context,
    required VoidCallback onLogout,
    required VoidCallback onDelete,
  }) {
    return [
      UserSettingsItem(
        icon: Icons.edit,
        title: 'Edit Profile',
        onTap: () {
          debugPrint('Edit Profile tapped');
        },
      ),
      UserSettingsItem(
        icon: Icons.lock_outline,
        title: 'Change Password',
        onTap: () {
          debugPrint('Change Password tapped');
        },
      ),
      UserSettingsItem(
        icon: Icons.delete_forever,
        title: 'Delete Account',
        onTap: onDelete, // This must be passed down from the page
        type: UserSettingsItemType.destructive,
      ),
      UserSettingsItem(
        icon: Icons.logout,
        title: 'Log Out',
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
          onLogout();
        },
        type: UserSettingsItemType.action,
      ),
    ];
  }
}
