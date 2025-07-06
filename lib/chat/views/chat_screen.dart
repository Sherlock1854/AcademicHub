// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../friend/models/friend.dart';               // ← import Friend
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import 'widgets/date_divider.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input_field.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final Friend friend;                       // ← add Friend field

  const ChatScreen({
    Key? key,
    required this.friend,                     // ← require it
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  late final Stream<List<ChatMessage>> _messages$;

  @override
  void initState() {
    super.initState();
    _messages$ = ChatService().messagesStream(widget.friend.id);
  }

  // void _refresh() {
  //   setState(() => _history = _chatService.getMessages());
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (_scrollController.hasClients) {
  //       _scrollController
  //           .jumpTo(_scrollController.position.maxScrollExtent);
  //     }
  //   });
  // }

  Future<void> _handleSend(String text) =>
      _chatService.sendMessage(chatId: widget.friend.id, text: text);

  Future<void> _handlePickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await _chatService.sendMessage(
        chatId: widget.friend.id,
        imagePath: file.path,
      );
    }
  }

  Future<void> _handleTakePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      await _chatService.sendMessage(
        chatId: widget.friend.id,
        imagePath: photo.path,
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.friend.imageUrl),  // ← dynamic pic
            ),
            const SizedBox(width: 12),
            Text(
              widget.friend.name,                                   // ← dynamic name
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1) THE “CARD” CHAT AREA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: _messages$,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final history = snapshot.data ?? [];
                      _scrollToBottom();

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        itemCount: history.length,
                        itemBuilder: (ctx, index) {
                          final msg = history[index];
                          final msgDate = msg.timestamp;
                          final prevDate = index > 0
                              ? history[index - 1].timestamp
                              : null;
                          final showDivider = prevDate == null ||
                              !(prevDate.year == msgDate.year &&
                                  prevDate.month == msgDate.month &&
                                  prevDate.day == msgDate.day);

                          // human-friendly date label
                          final now = DateTime.now();
                          String dateLabel;
                          if (now.year == msgDate.year &&
                              now.month == msgDate.month &&
                              now.day == msgDate.day) {
                            dateLabel = 'Today';
                          } else if (now
                              .subtract(const Duration(days: 1))
                              .year ==
                              msgDate.year &&
                              now
                                  .subtract(const Duration(days: 1))
                                  .month ==
                                  msgDate.month &&
                              now
                                  .subtract(const Duration(days: 1))
                                  .day ==
                                  msgDate.day) {
                            dateLabel = 'Yesterday';
                          } else {
                            dateLabel =
                                DateFormat('MMM d, yyyy').format(msgDate);
                          }

                          return Column(
                            crossAxisAlignment: msg.isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (showDivider)
                                DateDivider(date: dateLabel),
                              MessageBubble(
                                message: msg.text,
                                imagePath: msg.imagePath,
                                isSender: msg.isSender,
                                timestamp: msg.timestamp,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // 2) INPUT FIELD aligned to card width
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: MessageInputField(
              onSend: _handleSend,
              onImagePressed: _handlePickImage,
              onCameraPressed: _handleTakePhoto,
            ),
          ),
        ],
      ),
    );
  }
}
