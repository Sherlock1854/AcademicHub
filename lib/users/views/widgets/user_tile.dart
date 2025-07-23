import 'package:flutter/material.dart';
import '../../models/user_settings.dart';

class UserSettingsTile extends StatelessWidget {
  final UserSettingsItem item;
  final bool showDivider;

  const UserSettingsTile({
    super.key,
    required this.item,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    Color titleColor = item.type == UserSettingsItemType.destructive
        ? Colors.red
        : Colors.black87;

    return Column(
      children: [
        ListTile(
          leading: Icon(item.icon, color: Colors.blue),
          title: Text(
            item.title,
            style: TextStyle(color: titleColor),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: item.onTap,
        ),
        if (showDivider)
          Divider(height: 1, indent: 70, color: Colors.grey[300]),
      ],
    );
  }
}
