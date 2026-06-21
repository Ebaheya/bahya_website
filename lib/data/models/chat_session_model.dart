class ChatSessionModel {
  final String id;
  final String status;
  final String? maxRiskLevel;
  final String? lastEmotion;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const ChatSessionModel({
    required this.id,
    required this.status,
    this.maxRiskLevel,
    this.lastEmotion,
    this.startedAt,
    this.endedAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      maxRiskLevel: json['maxRiskLevel']?.toString(),
      lastEmotion: json['lastEmotion']?.toString(),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      endedAt: DateTime.tryParse(json['endedAt']?.toString() ?? ''),
    );
  }
}
