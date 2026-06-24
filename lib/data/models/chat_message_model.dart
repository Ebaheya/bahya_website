enum ChatSender { patient, bot }

class ChatMessageModel {
  final String? id;
  final ChatSender sender;
  final String message;
  final DateTime createdAt;
  // Risk signals are returned by the backend on BOT turns only, and only to
  // Doctor/Admin readers (FR-019). They are null in the patient chat flow.
  final String? riskLevel;
  final String? emotion;
  final bool? crisis;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.createdAt,
    this.riskLevel,
    this.emotion,
    this.crisis,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final rawSender = json['sender']?.toString().toUpperCase();

    return ChatMessageModel(
      id: json['id']?.toString(),
      sender: rawSender == 'BOT' ? ChatSender.bot : ChatSender.patient,
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      riskLevel: json['riskLevel']?.toString(),
      emotion: json['emotion']?.toString(),
      crisis: json['crisis'] is bool ? json['crisis'] as bool : null,
    );
  }

  factory ChatMessageModel.localUser(String message) {
    return ChatMessageModel(
      id: null,
      sender: ChatSender.patient,
      message: message,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessageModel.localBot(String message) {
    return ChatMessageModel(
      id: null,
      sender: ChatSender.bot,
      message: message,
      createdAt: DateTime.now(),
    );
  }
}
