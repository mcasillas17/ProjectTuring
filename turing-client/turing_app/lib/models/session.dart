class Session {
  const Session({
    required this.sessionId,
    required this.title,
    required this.updatedAt,
  });

  final String sessionId;
  final String? title;
  final DateTime updatedAt;

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: (json['sessionId'] ?? json['id']) as String,
      title: json['title'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
