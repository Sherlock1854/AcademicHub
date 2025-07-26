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
import '../../utilities/active_chat.dart';

class ChatScreen extends StatefulWidget {
  final Friend friend;
  const ChatScreen({Key? key, required this.friend}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _chatService = ChatService();
  final _botService = BotChatService();
  final _picker = ImagePicker();
  final _scrollCtrl = ScrollController();

  late final Stream<List<ChatMessage>> _messages$;
  bool _awaitingBot = false;

  bool get _isBotChat => widget.friend.id == 'chatbot';

  @override
  void initState() {
    super.initState();

    // mark this chat as “active”
    activeChatFriendId = widget.friend.id;

    // choose stream based on bot vs peer
    _messages$ =
        _isBotChat
            ? _botService.messagesStream()
            : _chatService.messagesStream(widget.friend.id);

    // if peer chat, mark incoming as seen and flip sender copy
    if (!_isBotChat) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _chatService.markMessagesAsSeen(widget.friend.id);
      });
    }
  }

  @override
  void dispose() {
    // no longer active
    activeChatFriendId = null;
    super.dispose();
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
      await _chatService.sendMessage(friendId: widget.friend.id, text: text);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: Image.network(
                  widget.friend.avatarUrl!, // always set
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (ctx, err, stack) => Image.asset(
                        'assets/images/fail.png', // fallback on load‐error
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.friend.name,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white, // ← makes the menu’s background white
            elevation: 4, // ← optional shadow
            onSelected: _handleMenuSelection,
            itemBuilder:
                (_) => [
                  PopupMenuItem(
                    value: 'pin',
                    child: Text(
                      widget.friend.pinned ? 'Unpin Friend' : 'Pin Friend',
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
                onSend:
                    _awaitingBot
                        ? (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please wait for bot reply…'),
                            ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(current ? 'Unpinned' : 'Pinned')));
    } else if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Delete Friend'),
              content: const Text(
                'Are you sure you want to delete this friend and all messages?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );
      if (confirm == true) {
        await friendService.deleteFriend(widget.friend.id);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Friend deleted')));
      }
    }
  }

  Widget _buildListView(List<ChatMessage> history) {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return ListView.builder(
      controller: _scrollCtrl,
      reverse: false,  // oldest at top, newest at bottom
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: history.length,
      itemBuilder: (ctx, i) {
        final msg  = history[i];
        final prev = i > 0 ? history[i - 1] : null;

        // strip time component
        final msgDate  = DateTime(msg.timestamp.year, msg.timestamp.month, msg.timestamp.day);
        final prevDate = prev != null
            ? DateTime(prev.timestamp.year, prev.timestamp.month, prev.timestamp.day)
            : null;

        // show divider if first item or date changed
        final showDivider = prevDate == null || msgDate != prevDate;

        // pick label
        String dateLabel;
        if (msgDate == today) {
          dateLabel = 'Today';
        } else if (msgDate == yesterday) {
          dateLabel = 'Yesterday';
        } else {
          dateLabel = DateFormat('MMM d, yyyy').format(msg.timestamp);
        }

        final bubble = MessageBubble(msg: msg);

        if (_isBotChat) {
          // for bot, no long-press menu
          return Column(
            crossAxisAlignment:
            msg.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (showDivider) DateDivider(date: dateLabel),
              bubble,
            ],
          );
        }

        // peer chat: allow edit/delete on long press
        return Column(
          crossAxisAlignment:
          msg.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showDivider) DateDivider(date: dateLabel),
            GestureDetector(
              key: ValueKey(msg.id),
              onLongPress: () => _showMessageOptions(context, msg),
              child: bubble,
            ),
          ],
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
                    msg.imageUrl != null ? Icons.image : Icons.edit,
                  ),
                  title: Text(
                    msg.imageUrl != null ? 'Edit Image' : 'Edit Text',
                  ),
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
              ],
            ),
          ),
    );
  }

  Future<void> _editMessage(BuildContext ctx, ChatMessage msg) async {
    final controller = TextEditingController(text: msg.text);

    final newText = await showDialog<String>(
      context: ctx,
      builder: (dialogCtx) {
        final screenWidth = MediaQuery.of(dialogCtx).size.width;
        final fieldWidth = screenWidth * 0.8;

        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Edit message'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: fieldWidth,
              maxWidth: fieldWidth, // ← fixed width
              maxHeight: 200,
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5, // ← scrollable after 5 lines
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: const Color(0xFF2196F3), // bubble‐blue
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
              ),
              onPressed: () => Navigator.pop(dialogCtx, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
              ),
              onPressed: () => Navigator.pop(dialogCtx, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
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
