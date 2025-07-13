// lib/screens/chat_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../friend/models/friend.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/gemini_service.dart';
import 'widgets/date_divider.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input_field.dart';

class ChatScreen extends StatefulWidget {
  final Friend friend;
  const ChatScreen({Key? key, required this.friend}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final GeminiService _botService = GeminiService();
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  late final Stream<List<ChatMessage>> _messages$;
  final List<ChatMessage> _history = [];

  @override
  void initState() {
    super.initState();
    if (widget.friend.id != 'chatbot') {
      _messages$ = _chatService.messagesStream(widget.friend.id);
    } else {
      final now = DateTime.now();
      _history.add(
        ChatMessage(
          id: 'bot_welcome',
          text: '👋 Hi! I\'m ChatBot. Ask me anything.',
          imageBase64: null,
          timestamp: now,
          isSender: false,
        ),
      );
    }
  }

  /// Jump to the "start" when reversed==true (i.e. bottom of the chat)
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    });
  }

  Future<void> _handleSend(String text) async {
    final now = DateTime.now();
    final msgId = now.millisecondsSinceEpoch.toString();
    final userMsg = ChatMessage(
      id: msgId,
      text: text,
      imageBase64: null,
      timestamp: now,
      isSender: true,
    );

    if (widget.friend.id == 'chatbot') {
      setState(() => _history.add(userMsg));
      _scrollToBottom();
      try {
        final reply = await _botService.ask(text);
        setState(
          () => _history.add(
            ChatMessage(
              id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
              text: reply,
              imageBase64: null,
              timestamp: DateTime.now(),
              isSender: false,
            ),
          ),
        );
      } catch (_) {}
      _scrollToBottom();
      return;
    }

    // Firestore mode – optimistic add
    setState(() => _history.add(userMsg));
    await _chatService.sendMessage(friendId: widget.friend.id, text: text);
    _scrollToBottom();
  }

  Future<void> _handlePickImage() async {
    if (widget.friend.id == 'chatbot') return;
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final b64 = base64Encode(await picked.readAsBytes());
    await _chatService.sendMessage(
      friendId: widget.friend.id,
      imageBase64: b64,
    );
    _scrollToBottom();
  }

  Future<void> _handleTakePhoto() async {
    if (widget.friend.id == 'chatbot') return;
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    final b64 = base64Encode(await picked.readAsBytes());
    await _chatService.sendMessage(
      friendId: widget.friend.id,
      imageBase64: b64,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isBot = widget.friend.id == 'chatbot';

    final avatar = widget.friend.avatarBase64.isNotEmpty
            ? MemoryImage(base64Decode(widget.friend.avatarBase64))
            : const AssetImage('assets/images/avatar_placeholder.png')
                as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: avatar,
              onBackgroundImageError: (_, __) => setState(() {}),
            ),
            const SizedBox(width: 12),
            Text(
              widget.friend.name,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Chat list ──
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
                  child:
                      isBot
                          ? _buildListView(_history)
                          : StreamBuilder<List<ChatMessage>>(
                            stream: _messages$,
                            builder: (ctx, snap) {
                              if (snap.hasError) {
                                return Center(
                                  child: Text('Error: ${snap.error}'),
                                );
                              }
                              if (!snap.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              // no more manual initial scroll!
                              return _buildListView(snap.data!);
                            },
                          ),
                ),
              ),
            ),
          ),

          // ── Input field ──
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

  Widget _buildListView(List<ChatMessage> history) {
    // Reverse the list so newest are at the top of the reversed view (i.e. bottom of screen)
    final reversed = history.reversed.toList();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: reversed.length,
      itemBuilder: (ctx, i) {
        final msg = reversed[i];
        final prev = i + 1 < reversed.length ? reversed[i + 1].timestamp : null;
        final showDivider =
            prev == null ||
            prev.year != msg.timestamp.year ||
            prev.month != msg.timestamp.month ||
            prev.day != msg.timestamp.day;

        final now = DateTime.now();
        final diff = now.difference(msg.timestamp).inDays;
        final dateLabel =
            diff == 0
                ? 'Today'
                : diff == 1
                ? 'Yesterday'
                : DateFormat('MMM d, yyyy').format(msg.timestamp);

        return GestureDetector(
          key: ValueKey(msg.id),
          onLongPress: () => _showMessageOptions(ctx, msg),
          child: Column(
            crossAxisAlignment:
                msg.isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            children: [
              if (showDivider) DateDivider(date: dateLabel),
              MessageBubble(msg: msg),
            ],
          ),
        );
      },
    );
  }

  void _showMessageOptions(BuildContext ctx, ChatMessage msg) {
    showModalBottomSheet(
      context: ctx,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    msg.imageBase64 != null ? Icons.image : Icons.edit,
                  ),
                  title: Text(
                    msg.imageBase64 != null ? 'Edit Image' : 'Edit Text',
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (msg.imageBase64 != null) {
                      _editImage(ctx, msg);
                    } else {
                      _editMessage(ctx, msg);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _chatService.deleteMessage(
                      friendId: widget.friend.id,
                      messageId: msg.id,
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _editMessage(BuildContext ctx, ChatMessage msg) async {
    final controller = TextEditingController(text: msg.text);
    final newText = await showDialog<String>(
      context: ctx,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit message'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (newText != null && newText.trim().isNotEmpty) {
      await _chatService.updateMessage(
        friendId: widget.friend.id,
        messageId: msg.id,
        newText: newText.trim(),
      );
    }
  }

  Future<void> _editImage(BuildContext ctx, ChatMessage msg) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final newB64 = base64Encode(await picked.readAsBytes());
    await _chatService.updateMessageImage(
      friendId: widget.friend.id,
      messageId: msg.id,
      newImageBase64: newB64,
    );
    _scrollToBottom();
  }
}
