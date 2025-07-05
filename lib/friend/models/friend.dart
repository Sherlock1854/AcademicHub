class Friend {
  final String name;
  final String lastMessage;
  final String time;
  final String imageUrl;
  final bool hasUnreadMessages;

  Friend({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.imageUrl,
    this.hasUnreadMessages = false,
  });
}
