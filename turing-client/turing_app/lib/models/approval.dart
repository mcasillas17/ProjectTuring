class Approval {
  const Approval({
    required this.approvalId,
    required this.toolName,
    required this.argsSummary,
    required this.status,
  });

  final String approvalId;
  final String toolName;
  final String argsSummary;
  final String status;

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      approvalId: json['approvalId'] as String,
      toolName: json['toolName'] as String,
      argsSummary: json['argsSummary'] as String? ?? '',
      status: json['status'] as String,
    );
  }
}
