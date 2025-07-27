// lib/screens/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool showRead;

  const MessageBubble({Key? key, required this.msg, this.showRead = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSender = msg.isSender;
    final hasImage = msg.imageUrl != null;
    final bgColor =
        hasImage
            ? Colors.transparent
            : (isSender ? const Color(0xFF2196F3) : const Color(0xFFF0F0F0));
    final borderRadius = BorderRadius.circular(20);
    final maxWidth = MediaQuery.of(context).size.width * 0.7;
    final timestampStr = DateFormat('h:mm a').format(msg.timestamp);

    final footerTextColor = hasImage
        ? Colors.white70
        : (isSender ? Colors.white70 : Colors.black54);
      final footerIconColor = Colors.white70;

    Widget footer = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (msg.edited) ...[
          Text(
            '(edited)',
            style: TextStyle(
              fontSize: 10,
              color: footerTextColor,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          timestampStr,
          style: TextStyle(
            fontSize: 10,
            color: footerTextColor,
          ),
        ),
        if (isSender && showRead) ...[
          const SizedBox(width: 4),
          Icon(
            // single tick when sent, double tick when seen
            msg.seen ? Icons.done_all : Icons.done,
            size: 14,
            // keep the same color regardless of seen-status
            color: footerIconColor,
          ),
        ],
      ],
    );

    Widget content;
    if (hasImage) {
      content = Stack(
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: Image.network(
              msg.imageUrl!,
              fit: BoxFit.cover,
              width: maxWidth,
              errorBuilder:
                  (c, e, st) => Image.asset(
                    'assets/images/fail.png',
                    fit: BoxFit.cover,
                    width: maxWidth,
                  ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: footer,
            ),
          ),
        ],
      );
    } else {
      content = Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg.text ?? '',
            style: TextStyle(
              color: isSender ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: footer,
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding:
              hasImage
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),
          child: content,
        ),
      ),
    );
  }
}
