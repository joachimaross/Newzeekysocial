class ChatRoom {
  final String id;
  final List<String> userIds;
  final String lastMessage;
  final DateTime lastMessageTimestamp;

  ChatRoom({
    required this.id,
    required this.userIds,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });
}
