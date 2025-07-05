import '../models/chat_message.dart';

class ChatService {
  final List<ChatMessage> _messages = [ /* your existing mock data */ ];

  // final List<ChatMessage> _messages = [
  //   ChatMessage(text: 'Hey, how are you?', timestamp: DateTime.now(), isSender: false),
  //   ChatMessage(text: 'I\'m good, thanks! How about you?', timestamp: DateTime.now(), isSender: true),
  //   // …etc.
  // ];

  List<ChatMessage> getMessages() => List.unmodifiable(_messages);

  void sendMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      imagePath: null,
      timestamp: DateTime.now(),
      isSender: true,
    ));
  }

  void sendImage(String path) {           // ← new
    _messages.add(ChatMessage(
      text: null,
      imagePath: path,
      timestamp: DateTime.now(),
      isSender: true,
    ));
  }
}
