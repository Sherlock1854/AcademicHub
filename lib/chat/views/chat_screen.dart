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

class ChatScreen extends StatefulWidget {
  final Friend friend;

  const ChatScreen({
    Key? key,
    required this.friend,
  }) : super(key: key);

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
      // Real-user chat: listen to Firestore
      _messages$ = _chatService.messagesStream(widget.friend.id);
    } else {
      // Bot chat: seed a welcome message
      _history.add(
        ChatMessage(
          text: '👋 Hi! I\'m ChatBot. Ask me anything.',
          imagePath: null,
          timestamp: DateTime.now(),
          isSender: false,
        ),
      );
    }
  }

  Future<void> _handleSend(String text) async {
    final userMsg = ChatMessage(
      text: text,
      imagePath: null,
      timestamp: DateTime.now(),
      isSender: true,
    );

    if (widget.friend.id == 'chatbot') {
      // ── BOT MODE ──
      setState(() => _history.add(userMsg));
      _scrollToBottom();

      try {
        final reply = await _botService.ask(text);
        final botMsg = ChatMessage(
          text: reply,
          imagePath: null,
          timestamp: DateTime.now(),
          isSender: false,
        );
        setState(() => _history.add(botMsg));
      } catch (e) {
        setState(() => _history.add(
          ChatMessage(
            text: '⚠️ Error: $e',
            imagePath: null,
            timestamp: DateTime.now(),
            isSender: false,
          ),
        ));
      }

      _scrollToBottom();
      return;
    }

    // ── FIRESTORE MODE ──
    setState(() => _history.add(userMsg)); // optimistically show
    _scrollToBottom();

    await _chatService.sendMessage(
      chatId: widget.friend.id,
      text: text,
    );
    // Firestore stream will update the UI
  }

  Future<void> _handlePickImage() async {
    if (widget.friend.id == 'chatbot') return; // no images for bot

    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await _chatService.sendMessage(
        chatId: widget.friend.id,
        imagePath: file.path,
      );
    }
  }

  Future<void> _handleTakePhoto() async {
    if (widget.friend.id == 'chatbot') return; // no images for bot

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
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
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
        leading:
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.of(context).pop()),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.friend.imageUrl),
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
          // 1) Chat area
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
                  child: isBot
                  // Bot chat: local history
                      ? _buildListView(_history)
                  // Real-user chat: Firestore stream
                      : StreamBuilder<List<ChatMessage>>(
                    stream: _messages$,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final history = snapshot.data ?? [];
                      return _buildListView(history);
                    },
                  ),
                ),
              ),
            ),
          ),

          // 2) Input field
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

  /// Shared ListView builder for both bot and real‐user chats
  Widget _buildListView(List<ChatMessage> history) {
    _scrollToBottom();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      itemCount: history.length,
      itemBuilder: (ctx, index) {
        final msg = history[index];
        final msgDate = msg.timestamp;
        final prevDate = index > 0 ? history[index - 1].timestamp : null;
        final showDivider = prevDate == null ||
            !(prevDate.year == msgDate.year &&
                prevDate.month == msgDate.month &&
                prevDate.day == msgDate.day);

        // Human-friendly date label
        final now = DateTime.now();
        String dateLabel;
        if (now.year == msgDate.year &&
            now.month == msgDate.month &&
            now.day == msgDate.day) {
          dateLabel = 'Today';
        } else if (now.subtract(const Duration(days: 1)).year == msgDate.year &&
            now.subtract(const Duration(days: 1)).month == msgDate.month &&
            now.subtract(const Duration(days: 1)).day == msgDate.day) {
          dateLabel = 'Yesterday';
        } else {
          dateLabel = DateFormat('MMM d, yyyy').format(msgDate);
        }

        return Column(
          crossAxisAlignment:
          msg.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showDivider) DateDivider(date: dateLabel),
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
  }
}
