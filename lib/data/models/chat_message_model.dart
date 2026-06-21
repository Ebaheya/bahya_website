enum ChatSender { patient, bot }

class ChatMessageModel {
  final String? id;
  final ChatSender sender;
  final String message;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final rawSender = json['sender']?.toString().toUpperCase();

    return ChatMessageModel(
      id: json['id']?.toString(),
      sender: rawSender == 'BOT' ? ChatSender.bot : ChatSender.patient,
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
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
