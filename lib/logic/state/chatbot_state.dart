import 'package:bahya_app/data/models/chat_message_model.dart';

class ChatbotState {
  final bool isLoading;
  final bool isSending;
  final String? sessionId;
  final String? errorMessage;
  final List<ChatMessageModel> messages;

  const ChatbotState({
    this.isLoading = false,
    this.isSending = false,
    this.sessionId,
    this.errorMessage,
    this.messages = const [],
  });

  ChatbotState copyWith({
    bool? isLoading,
    bool? isSending,
    String? sessionId,
    bool clearSessionId = false,
    String? errorMessage,
    bool clearError = false,
    List<ChatMessageModel>? messages,
  }) {
    return ChatbotState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      messages: messages ?? this.messages,
    );
  }
}
