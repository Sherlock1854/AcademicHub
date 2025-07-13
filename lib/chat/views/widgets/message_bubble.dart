// lib/screens/widgets/message_bubble.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage msg;

  const MessageBubble({
    Key? key,
    required this.msg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSender = msg.isSender;
    final hasImage = msg.imageBase64 != null;
    final bgColor = hasImage
        ? Colors.transparent
        : (isSender ? Colors.blue : const Color(0xFFF0F0F0));
    final borderRadius = BorderRadius.circular(20);
    final maxWidth = MediaQuery.of(context).size.width * 0.7;

    Widget content;
    if (hasImage) {
      // Decode Base64 and display
      final bytes = base64Decode(msg.imageBase64!);
      content = ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: maxWidth,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/fail.png',
              fit: BoxFit.cover,
              width: maxWidth,
            );
          },
        ),
      );
    } else {
      final display = msg.text! + (msg.edited ? ' (edited)' : '');
      content = Text(
        display,
        style: TextStyle(
          color: isSender ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      );
    }

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 60, 12),
              child: content,
            ),
            Positioned(
              right: 12,
              bottom: 8,
              child: Row(
                children: [
                  Text(
                    DateFormat('h:mm a').format(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSender ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  if (isSender) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
