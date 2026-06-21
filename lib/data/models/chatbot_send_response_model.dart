class ChatbotSendResponseModel {
  final String sessionId;
  final String? patientMessageId;
  final String? botMessageId;
  final String reply;

  const ChatbotSendResponseModel({
    required this.sessionId,
    required this.patientMessageId,
    required this.botMessageId,
    required this.reply,
  });

  factory ChatbotSendResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatbotSendResponseModel(
      sessionId: json['sessionId']?.toString() ?? '',
      patientMessageId: json['patientMessageId']?.toString(),
      botMessageId: json['botMessageId']?.toString(),
      reply: json['reply']?.toString() ?? '',
    );
  }
}
