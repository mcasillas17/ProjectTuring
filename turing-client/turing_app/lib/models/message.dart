class Message {
  const Message({
    required this.messageId,
    required this.role,
    required this.content,
    required this.sequence,
    required this.createdAt,
  });

  final String messageId;
  final String role;
  final String content;
  final int sequence;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: (json['messageId'] ?? json['id']) as String,
      role: json['role'] as String,
      content: json['content'] as String,
      sequence: (json['sequence'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
