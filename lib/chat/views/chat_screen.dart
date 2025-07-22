// lib/screens/chat_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../friend/models/friend.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/bot_chat_service.dart';
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
  final _chatService = ChatService();
  final _botService  = BotChatService();
  final _picker      = ImagePicker();
  final _scrollCtrl  = ScrollController();

  late final Stream<List<ChatMessage>> _messages$;
  bool _awaitingBot = false;

  bool get _isBotChat => widget.friend.id == 'chatbot';

  @override
  void initState() {
    super.initState();
    // pick the right stream
    _messages$ = _isBotChat
        ? _botService.messagesStream()
        : _chatService.messagesStream(widget.friend.id);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0.0);
    });
  }

  Future<void> _handleSend(String text) async {
    if (text.trim().isEmpty) return;

    if (_isBotChat) {
      setState(() => _awaitingBot = true);
      await _botService.askAndSave(text);
      setState(() => _awaitingBot = false);
    } else {
      await _chatService.sendMessage(
        friendId: widget.friend.id,
        text: text,
      );
    }
    _scrollToBottom();
  }

  Future<void> _handlePickImage() async {
    if (_isBotChat) return; // no images in bot chat
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final b64 = base64Encode(await file.readAsBytes());
    await _chatService.sendMessage(
      friendId: widget.friend.id,
      imageBase64: b64,
    );
    _scrollToBottom();
  }

  Future<void> _handleTakePhoto() async {
    if (_isBotChat) return;
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    final b64 = base64Encode(await file.readAsBytes());
    await _chatService.sendMessage(
      friendId: widget.friend.id,
      imageBase64: b64,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
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
            CircleAvatar(radius: 20, backgroundImage: avatar),
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
          //── Message List ───────────────────────────────────────────
          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: _messages$,
                    builder: (ctx, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Error: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      return _buildListView(snap.data!);
                    },
                  ),
                ),
              ),
            ),
          ),

          //── Input Bar ───────────────────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: MessageInputField(
                isBot: _isBotChat,
                onSend: _awaitingBot
                    ? (msg) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please wait for bot reply…')),
                  );
                }
                    : _handleSend,
                onImagePressed: _handlePickImage,
                onCameraPressed: _handleTakePhoto,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<ChatMessage> history) {
    final rev = history.reversed.toList();
    return ListView.builder(
      controller: _scrollCtrl,
      reverse: true,
      padding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: rev.length,
      itemBuilder: (ctx, i) {
        final msg  = rev[i];
        final prev = i + 1 < rev.length ? rev[i + 1] : null;

        final showDivider = prev == null ||
            prev.timestamp.year  != msg.timestamp.year ||
            prev.timestamp.month != msg.timestamp.month ||
            prev.timestamp.day   != msg.timestamp.day;

        final diff =
            DateTime.now().difference(msg.timestamp).inDays;
        final dateLabel = diff == 0
            ? 'Today'
            : diff == 1
            ? 'Yesterday'
            : DateFormat('MMM d, yyyy')
            .format(msg.timestamp);

        final bubble = MessageBubble(msg: msg);

        // Bot chat: no long-press
        if (_isBotChat) {
          return Column(
            crossAxisAlignment: msg.isSender
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (showDivider) DateDivider(date: dateLabel),
              bubble,
            ],
          );
        }

        // Peer chat: allow edit/delete
        return GestureDetector(
          key: ValueKey(msg.id),
          onLongPress: () => _showMessageOptions(context, msg),
          child: Column(
            crossAxisAlignment: msg.isSender
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (showDivider) DateDivider(date: dateLabel),
              bubble,
            ],
          ),
        );
      },
    );
  }

  void _showMessageOptions(BuildContext ctx, ChatMessage msg) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading:
            Icon(msg.imageBase64 != null ? Icons.image : Icons.edit),
            title: Text(
                msg.imageBase64 != null ? 'Edit Image' : 'Edit Text'),
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
        ]),
      ),
    );
  }

  Future<void> _editMessage(BuildContext ctx, ChatMessage msg) async {
    final controller = TextEditingController(text: msg.text);
    final newText = await showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (newText != null && newText.trim().isNotEmpty) {
      await _chatService.updateMessage(
        friendId: widget.friend.id,
        messageId: msg.id,
        newText: newText.trim(),
      );
      _scrollToBottom();
    }
  }

  Future<void> _editImage(BuildContext ctx, ChatMessage msg) async {
    final picked =
    await _picker.pickImage(source: ImageSource.gallery);
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
