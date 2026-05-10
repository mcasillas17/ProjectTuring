enum MessageType {
  text,
  loading,
  deviceStatus, // e.g. "Light is ON" card
}

class ChatMessage {
  final String id;
  final bool isUser;
  final MessageType type;
  final String text;
  final Map<String, dynamic>? metadata; // Extra data for rich widgets

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.type = MessageType.text,
    this.metadata,
  });
}
