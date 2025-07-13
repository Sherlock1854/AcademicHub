// lib/screens/chat_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../friend/models/friend.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import 'widgets/date_divider.dart';
import 'widgets/message_bubble.dart';
import 'widgets/message_input_field.dart';
import 'package:intl/intl.dart';
import '../services/gemini_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    if (widget.friend.id != 'chatbot') {
      // Real‐user chat: listen under Users/{me}/friends/{friendId}/messages
      _messages$ = _chatService.messagesStream(widget.friend.id);
    } else {
      // Bot chat: seed a welcome message
      _history.add(
        ChatMessage(
          text: '👋 Hi! I\'m ChatBot. Ask me anything.',
          imageUrl: null,
          timestamp: DateTime.now(),
          isSender: false,
        ),
      );
    }
  }

  Future<void> _handleSend(String text) async {
    final userMsg = ChatMessage(
      text: text,
      imageUrl: null,
      timestamp: DateTime.now(),
      isSender: true,
    );

    if (widget.friend.id == 'chatbot') {
      // ── BOT MODE ──
      setState(() => _history.add(userMsg));
      _scrollToBottom();

      try {
        final reply = await _botService.ask(text);
        setState(
          () => _history.add(
            ChatMessage(
              text: reply,
              imageUrl: null,
              timestamp: DateTime.now(),
              isSender: false,
            ),
          ),
        );
      } catch (e) {
        setState(
          () => _history.add(
            ChatMessage(
              text: '⚠️ Error: $e',
              imageUrl: null,
              timestamp: DateTime.now(),
              isSender: false,
            ),
          ),
        );
      }

      _scrollToBottom();
      return;
    }

    // ── FIRESTORE MODE ──
    setState(() => _history.add(userMsg)); // optimistic UI
    _scrollToBottom();

    await _chatService.sendMessage(friendId: widget.friend.id, text: text);
    // real data will stream in via messagesStream
  }

  Future<void> _handlePickImage() async {
    if (widget.friend.id == 'chatbot') return;
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);
    try {
      final file = File(picked.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // ← use instanceFor(...) here
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://academichub-c1068.firebasestorage.app',
      );
      final storageRef = storage
          .ref()
          .child('chat_images')
          .child(widget.friend.id)
          .child(fileName);

      final snapshot = await storageRef.putFile(file).whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _chatService.sendMessage(
        friendId: widget.friend.id,
        imageUrl: downloadUrl,
      );
    } catch (e, st) {
      debugPrint('🔥 upload error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _handleTakePhoto() async {
    if (widget.friend.id == 'chatbot') return;
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    setState(() => _isUploading = true);
    try {
      final file = File(picked.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://academichub-c1068.firebasestorage.app',
      );
      final storageRef = storage
          .ref()
          .child('chat_images')
          .child(widget.friend.id)
          .child(fileName);

      final snapshot = await storageRef.putFile(file).whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _chatService.sendMessage(
        friendId: widget.friend.id,
        imageUrl: downloadUrl,
      );
    } catch (e, st) {
      debugPrint('🔥 camera upload error: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBot = widget.friend.id == 'chatbot';

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
              backgroundImage: NetworkImage(widget.friend.imageUrl),
              onBackgroundImageError: (_, __) {
                // rebuild to pick up the AssetImage fallback
                setState(() {});
              },
              foregroundImage: AssetImage('assets/images/fail.png'),
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
          // Chat area
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
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final history = snap.data ?? [];
                              return _buildListView(history);
                            },
                          ),
                ),
              ),
            ),
          ),

          // Input field
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
    _scrollToBottom();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: history.length,
      itemBuilder: (ctx, i) {
        final msg = history[i];
        final prev = i > 0 ? history[i - 1].timestamp : null;
        final msgDate = msg.timestamp;
        final showDivider =
            prev == null ||
            prev.year != msgDate.year ||
            prev.month != msgDate.month ||
            prev.day != msgDate.day;

        final now = DateTime.now();
        String dateLabel;
        if (now.difference(msgDate).inDays == 0) {
          dateLabel = 'Today';
        } else if (now.difference(msgDate).inDays == 1) {
          dateLabel = 'Yesterday';
        } else {
          dateLabel = DateFormat('MMM d, yyyy').format(msgDate);
        }

        return Column(
          crossAxisAlignment:
              msg.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showDivider) DateDivider(date: dateLabel),
            MessageBubble(msg: msg),
          ],
        );
      },
    );
  }
}
