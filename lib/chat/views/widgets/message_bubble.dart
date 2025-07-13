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
    final bgColor = msg.imageUrl != null
        ? Colors.transparent
        : (isSender ? Colors.blue : const Color(0xFFF0F0F0));
    final borderRadius = BorderRadius.circular(20);
    final maxWidth = MediaQuery.of(context).size.width * 0.7;

    Widget content;
    if (msg.imageUrl != null) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          msg.imageUrl!,
          fit: BoxFit.cover,
          width: maxWidth,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to local fail.png on any load error
            return Image.asset(
              'assets/images/fail.png',
              fit: BoxFit.cover,
              width: maxWidth,
            );
          },
        ),
      );
    } else {
      content = Text(
        msg.text ?? '',
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
