// lib/screens/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage msg;

  const MessageBubble({Key? key, required this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSender      = msg.isSender;
    final hasImage      = msg.imageUrl != null;
    final bgColor       = hasImage
        ? Colors.transparent
        : (isSender ? const Color(0xFF2196F3) : const Color(0xFFF0F0F0));
    final borderRadius  = BorderRadius.circular(20);
    final maxWidth      = MediaQuery.of(context).size.width * 0.7;
    final timestampStr  = DateFormat('h:mm a').format(msg.timestamp);

    Widget footer = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (msg.edited) ...[
          Text(
            '(edited)',
            style: TextStyle(
              fontSize: 10,
              color: isSender ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 4),
        ],
        Text(
          timestampStr,
          style: TextStyle(
            fontSize: 10,
            color: isSender ? Colors.white70 : Colors.black54,
          ),
        ),
        if (isSender) ...[
          const SizedBox(width: 4),
          // always grey for outgoing
          const Icon(
            Icons.done_all,
            size: 14,
            color: Colors.white70,
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
              errorBuilder: (c, e, st) => Image.asset(
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
          padding: hasImage
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
          ),
          child: content,
        ),
      ),
    );
  }
}
