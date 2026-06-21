
import 'package:bahya_app/data/models/chat_message_model.dart';
import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bloc/bloc.dart';

import '../state/chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final AppRepository repository;

  ChatbotCubit({required this.repository}) : super(const ChatbotState());

  Future<void> loadLastSession() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final sessions = await repository.getSessions(page: 1, pageSize: 1);

      if (sessions.isEmpty) {
        emit(state.copyWith(isLoading: false, messages: const []));
        return;
      }

      final sessionId = sessions.first.id;
      final messages = await repository.getMessages(sessionId: sessionId);

      emit(
        state.copyWith(
          isLoading: false,
          sessionId: sessionId,
          messages: messages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    final message = text.trim();
    if (message.isEmpty || state.isSending) return;

    final optimisticMessages = [
      ...state.messages,
      ChatMessageModel.localUser(message),
    ];

    emit(
      state.copyWith(
        isSending: true,
        clearError: true,
        messages: optimisticMessages,
      ),
    );

    try {
      final response = await repository.sendMessage(
        sessionId: state.sessionId,
        message: message,
      );

      final nextMessages = [
        ...optimisticMessages,
        ChatMessageModel.localBot(response.reply),
      ];

      emit(
        state.copyWith(
          isSending: false,
          sessionId: response.sessionId,
          messages: nextMessages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: e.toString(),
          messages: state.messages,
        ),
      );
    }
  }
}
