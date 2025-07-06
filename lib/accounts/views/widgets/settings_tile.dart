import 'package:flutter/material.dart';
import '../../models/settings.dart'; // <--- UPDATED IMPORT PATH

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
    Color titleColor;
    if (item.type == SettingsItemType.destructive) {
      titleColor = Colors.red;
    } else {
      titleColor = Colors.black87;
    }

    return Column(
      children: [
        ListTile(
          leading: Icon(item.icon, color: Colors.blueGrey[700]),
          title: Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              color: titleColor,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: item.onTap,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 70,
            color: Colors.grey[300],
          ),
      ],
    );
  }
}