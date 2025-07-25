import 'package:flutter/material.dart';

class MessageInputField extends StatefulWidget {
  final void Function(String) onSend;
  final VoidCallback onImagePressed;
  final VoidCallback onCameraPressed;
  final bool isBot;

  const MessageInputField({
    required this.onSend,
    required this.onImagePressed,
    required this.onCameraPressed,
    this.isBot = false,
    super.key,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _canSend) {
        setState(() => _canSend = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (!_canSend) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final showMediaIcons = !widget.isBot;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 1) Growing text field
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: widget.isBot ? 'Ask me anything…' : 'Type a message',
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 2) Media icons
            if (showMediaIcons) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.image_outlined),
                    onPressed: widget.onImagePressed,
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: widget.onCameraPressed,
                  ),
                ),
              ),
            ],

            // 3) Send button
            SizedBox(
              height: 48,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _canSend ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _canSend ? _send : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
