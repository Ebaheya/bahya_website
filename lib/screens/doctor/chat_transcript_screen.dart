import 'package:bahya_app/data/models/chat_message_model.dart';
import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Read-only chat transcript for staff (Doctor/Admin). Loads the real
/// conversation from GET /chatbot/sessions/:id/messages, which includes the
/// per-turn risk signals on BOT turns (FR-019, staff-only).
class ChatTranscriptScreen extends StatefulWidget {
  final String sessionId;

  const ChatTranscriptScreen({super.key, required this.sessionId});

  @override
  State<ChatTranscriptScreen> createState() => _ChatTranscriptScreenState();
}

class _ChatTranscriptScreenState extends State<ChatTranscriptScreen> {
  final AppRepository _repository = AppRepository();
  late Future<List<ChatMessageModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getMessages(sessionId: widget.sessionId);
  }

  void _reload() {
    setState(() {
      _future = _repository.getMessages(sessionId: widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: context.tr('محادثة المريضة'),
        subTitle: context.tr('المحادثة الكاملة مع المساعد الذكي'),
        isHome: false,
      ),
      body: SafeArea(
        child: FutureBuilder<List<ChatMessageModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: customLoading());
            }
            if (snapshot.hasError) {
              return _ErrorView(onRetry: _reload);
            }
            final messages = snapshot.data ?? const [];
            if (messages.isEmpty) {
              return Center(child: Text(context.tr('لا توجد رسائل في هذه المحادثة')));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, i) => _MessageBubble(message: messages[i]),
            );
          },
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.sender == ChatSender.bot;
    final align = isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final bubbleColor =
        isBot ? const Color(0xFFEFE7F7) : const Color(0xFFD9F0E6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(message.message, style: const TextStyle(fontSize: 15)),
          ),
          if (isBot && (message.riskLevel != null || message.crisis == true))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _RiskChips(message: message),
            ),
        ],
      ),
    );
  }
}

class _RiskChips extends StatelessWidget {
  final ChatMessageModel message;

  const _RiskChips({required this.message});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        if (message.riskLevel != null)
          _chip(message.riskLevel!, _riskColor(message.riskLevel!)),
        if (message.crisis == true) _chip(context.tr('أزمة'), Colors.red),
        if (message.emotion != null && message.emotion!.isNotEmpty)
          _chip(message.emotion!, Colors.blueGrey),
      ],
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

Color _riskColor(String risk) {
  switch (risk.toUpperCase()) {
    case 'CRITICAL':
      return Colors.red;
    case 'HIGH':
      return Colors.deepOrange;
    case 'MEDIUM':
      return Colors.orange;
    default:
      return Colors.green;
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr('تعذّر تحميل المحادثة')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(context.tr('إعادة المحاولة')),
          ),
        ],
      ),
    );
  }
}
