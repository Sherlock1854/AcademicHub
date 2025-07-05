// message_bubble.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String? message;
  final String? imagePath;
  final bool isSender;
  final DateTime timestamp;

  const MessageBubble({
    Key? key,
    this.message,
    this.imagePath,
    required this.isSender,
    required this.timestamp,
  }) : assert(message != null || imagePath != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // common bubble decoration
    final bgColor = imagePath != null
        ? Colors.transparent
        : (isSender ? Colors.blue : const Color(0xFFF0F0F0));

    final borderRadius = BorderRadius.circular(20.0);
    final maxWidth = MediaQuery.of(context).size.width * 0.7;

    // the actual message text
    final textWidget = Text(
      message!,
      style: TextStyle(
        color: isSender ? Colors.white : Colors.black,
        fontSize: 16,
      ),
    );

    // build the bubble as a Stack
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),

        // Stack lets the text fill the whole width, then overlay
        child: Stack(
          children: [
            // 1) padded content — right padding leaves space for timestamp
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,    // left
                12,    // top
                // leave ~60px on the right so only the last line wraps
                60,
                12,    // bottom
              ),
              child: imagePath != null
                  ? ClipRRect(
                borderRadius: borderRadius,
                child: Image.file(File(imagePath!), fit: BoxFit.cover),
              )
                  : textWidget,
            ),

            // 2) positioned timestamp (and grey tick) in bottom-right
            Positioned(
              right: 12,
              bottom: 8,
              child: Row(
                children: [
                  Text(
                    DateFormat('h:mm a').format(timestamp),
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
