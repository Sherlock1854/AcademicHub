// lib/screens/chat_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../friend/models/friend.dart';
import '../../friend/services/friend_service.dart';
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

    // choose stream based on bot vs peer
    _messages$ = _isBotChat
        ? _botService.messagesStream()
        : _chatService.messagesStream(widget.friend.id);

    // if peer chat, mark incoming as seen and flip sender copy
    if (!_isBotChat) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chatService.markMessagesAsSeen(widget.friend.id);
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.minScrollExtent);
      }
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
    if (_isBotChat) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final imageUrl = await _chatService.uploadImage(file, widget.friend.id);
    await _chatService.sendMessage(
      friendId: widget.friend.id,
      imageUrl: imageUrl,
    );
    _scrollToBottom();
  }

  Future<void> _handleTakePhoto() async {
    if (_isBotChat) return;
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final file = File(picked.path);
    final imageUrl = await _chatService.uploadImage(file, widget.friend.id);
    await _chatService.sendMessage(
      friendId: widget.friend.id,
      imageUrl: imageUrl,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = (widget.friend.avatarUrl != null && widget.friend.avatarUrl!.isNotEmpty)
        ? NetworkImage(widget.friend.avatarUrl!)
        : const AssetImage('assets/images/avatar_placeholder.png') as ImageProvider;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(radius: 20, backgroundImage: avatarImage),
            const SizedBox(width: 12),
            Text(
              widget.friend.name,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'pin',
                child: Text(
                    widget.friend.pinned ? 'Unpin Friend' : 'Pin Friend'
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Friend'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list
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
                    builder: (ctx, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Error: ${snap.error}'));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _buildListView(snap.data!);
                    },
                  ),
                ),
              ),
            ),
          ),
          // Input bar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: MessageInputField(
                isBot: _isBotChat,
                onSend: _awaitingBot
                    ? (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please wait for bot reply…')),
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

  void _handleMenuSelection(String value) async {
    final friendService = FriendService();
    if (value == 'pin') {
      final current = widget.friend.pinned;
      await friendService.pinFriend(widget.friend.id, !current);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(current ? 'Unpinned' : 'Pinned')),
      );
    } else if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Friend'),
          content: const Text('Are you sure you want to delete this friend and all messages?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      );
      if (confirm == true) {
        await friendService.deleteFriend(widget.friend.id);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend deleted')),
        );
      }
    }
  }

  Widget _buildListView(List<ChatMessage> history) {
    final rev = history.reversed.toList();
    return ListView.builder(
      controller: _scrollCtrl,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: rev.length,
      itemBuilder: (ctx, i) {
        final msg  = rev[i];
        final prev = i + 1 < rev.length ? rev[i + 1] : null;

        final showDivider = prev == null ||
            prev.timestamp.year  != msg.timestamp.year ||
            prev.timestamp.month != msg.timestamp.month ||
            prev.timestamp.day   != msg.timestamp.day;

        final diff = DateTime.now().difference(msg.timestamp).inDays;
        final dateLabel = diff == 0
            ? 'Today'
            : diff == 1
            ? 'Yesterday'
            : DateFormat('MMM d, yyyy').format(msg.timestamp);

        return Column(
          crossAxisAlignment:
          msg.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showDivider) DateDivider(date: dateLabel),
            GestureDetector(
              key: ValueKey(msg.id),
              onLongPress: _isBotChat ? null : () => _showMessageOptions(context, msg),
              child: MessageBubble(msg: msg),
            ),
          ],
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
            leading: Icon(msg.imageUrl != null ? Icons.image : Icons.edit),
            title: Text(msg.imageUrl != null ? 'Edit Image' : 'Edit Text'),
            onTap: () {
              Navigator.pop(ctx);
              if (msg.imageUrl != null) {
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
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
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
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final newUrl = await _chatService.uploadImage(file, widget.friend.id);
    await _chatService.updateMessageImage(
      friendId: widget.friend.id,
      messageId: msg.id,
      newImageUrl: newUrl,
    );
    _scrollToBottom();
  }
}
