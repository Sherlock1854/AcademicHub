import 'package:flutter/material.dart';

// Represents a single item in the settings list
class SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap; // Callback for when the item is tapped
  final SettingsItemType type; // To distinguish different types of settings (e.g., destructive actions)

  SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.type = SettingsItemType.standard,
  });
}

// Enum to define different types of settings items
enum SettingsItemType {
  standard,
  destructive, // For actions like 'Delete Account'
  action, // For general actions like 'Log Out'
}