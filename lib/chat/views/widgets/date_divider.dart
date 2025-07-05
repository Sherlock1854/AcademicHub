// date_divider.dart
import 'package:flutter/material.dart';

class DateDivider extends StatelessWidget {
  final String date;
  const DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 1, height: 1, color: Color(0xFFCCCCCC))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              date,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(thickness: 1, height: 1, color: Color(0xFFCCCCCC))),
        ],
      ),
    );
  }
}
