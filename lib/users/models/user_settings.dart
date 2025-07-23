import 'package:flutter/material.dart';

/// Represents a single item in the user settings list.
class UserSettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final UserSettingsItemType type;

  UserSettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.type = UserSettingsItemType.standard,
  });
}

enum UserSettingsItemType {
  standard,
  destructive,
  action,
}
