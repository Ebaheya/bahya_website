import 'dart:async';
import 'package:bahya_app/data/models/chat_message_model.dart';
import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/logic/cubit/chatbot_cubit.dart';
import 'package:bahya_app/logic/state/chatbot_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBotScreen extends StatelessWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ChatbotCubit(repository: AppRepository(webService: WebService()))
            ..loadLastSession(),
      child: const _ChatBotView(),
    );
  }
}

class _ChatBotView extends StatefulWidget {
  const _ChatBotView();

  @override
  State<_ChatBotView> createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<_ChatBotView> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    messageController.clear();
    context.read<ChatbotCubit>().sendMessage(text);
    _scrollToBottomDelayed();
  }

  void _scrollToBottomDelayed() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final botSize = responsiveSize(context, 0.45, min: 165, max: 210);

    return BlocConsumer<ChatbotCubit, ChatbotState>(
      listener: (context, state) {
        _scrollToBottomDelayed();

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          customDialog(
            context: context,
            title: 'خطأ',
            message: state.errorMessage!,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: customAppBar(
            title: 'محادثة مع المساعد',
            subTitle: 'أنا هنا لمساعدتك والإجابة على استفساراتك',
            isHome: false,
            context: context,
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: _buildMessages(context, state)),
                    chatInput(context, state),
                  ],
                ),
                Positioned(
                  left: getScreenHeight(context) * 0.023 - botSize * 0.5,
                  bottom: getScreenHeight(context) * 0.4,
                  child: InteractiveBotCharacter(responsiveSize: botSize),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessages(BuildContext context, ChatbotState state) {
    if (state.isLoading) {
      return Center(child: customLoading());
    }

    final messages = state.messages;

    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.04, min: 16, max: 24),
        vertical: responsiveHeight(context, 0.02, min: 12, max: 22),
      ),
      child: Column(
        children: [
          if (messages.isEmpty)
            botMessage(
              context,
              title: 'مساعد رِفْق',
              message:
                  'مرحباً 👋\nأنا مساعدك الذكي. يمكنك سؤالي عن الأعراض، العلاجات، المواعيد أو أي استفسار آخر.',
              time: _formatTime(DateTime.now()),
            )
          else
            ...messages.map((message) {
              final isBot = message.sender == ChatSender.bot;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: responsiveHeight(context, 0.025),
                ),
                child: isBot
                    ? botMessage(
                        context,
                        title: 'مساعد رِفْق',
                        message: message.message,
                        time: _formatTime(message.createdAt),
                      )
                    : userMessage(
                        context,
                        message: message.message,
                        time: _formatTime(message.createdAt),
                      ),
              );
            }),
          if (state.isSending)
            Padding(
              padding: EdgeInsets.only(top: responsiveHeight(context, 0.01)),
              child: botMessage(
                context,
                title: 'مساعد رِفْق',
                message: 'جاري كتابة الرد...',
                time: _formatTime(DateTime.now()),
              ),
            ),
          SizedBox(height: responsiveHeight(context, 0.15)),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  Widget botMessage(
    BuildContext context, {
    required String title,
    required String message,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        botAvatar(context),
        SizedBox(width: responsiveSize(context, 0.025, min: 10, max: 14)),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.04, min: 16, max: 22),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFF4D6EF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8A2BE2).withOpacity(0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                customText(
                  text: title,
                  size: responsiveSize(context, 0.038, min: 14, max: 18),
                  color: const Color(0xFFFF5FA2),
                  isCenter: false,
                ),
                SizedBox(height: responsiveHeight(context, 0.012)),
                customText(
                  text: message,
                  size: responsiveSize(context, 0.04, min: 15, max: 20),
                  color: const Color(0xFF4A2240),
                  bold: false,
                  isCenter: false,
                  maxLines: 50,
                ),
                SizedBox(height: responsiveHeight(context, 0.012)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: customText(
                    text: time,
                    size: responsiveSize(context, 0.032, min: 12, max: 14),
                    color: Colors.grey,
                    bold: false,
                    isEnglish: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget userMessage(
    BuildContext context, {
    required String message,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Expanded(
          flex: 5,
          child: Container(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.04, min: 16, max: 22),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF69B4), Color(0xFF8A2BE2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8A2BE2).withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                customText(
                  text: message,
                  size: responsiveSize(context, 0.04, min: 15, max: 20),
                  color: Colors.white,
                  bold: false,
                  isCenter: false,
                  maxLines: 50,
                ),
                SizedBox(height: responsiveHeight(context, 0.008)),
                customText(
                  text: '$time ✓✓',
                  size: responsiveSize(context, 0.03, min: 11, max: 14),
                  color: Colors.white.withOpacity(0.8),
                  bold: false,
                  isEnglish: true,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.025, min: 10, max: 14)),
        userAvatar(context),
      ],
    );
  }

  Widget botAvatar(BuildContext context) {
    return Container(
      width: responsiveSize(context, 0.15, min: 54, max: 70),
      height: responsiveSize(context, 0.15, min: 54, max: 70),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFF69B4), Color(0xFF8A2BE2)],
        ),
      ),
      child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 34),
    );
  }

  Widget userAvatar(BuildContext context) {
    return Container(
      width: responsiveSize(context, 0.13, min: 48, max: 62),
      height: responsiveSize(context, 0.13, min: 48, max: 62),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD9EA),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF69B4).withOpacity(0.15),
            blurRadius: 18,
          ),
        ],
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
    );
  }

  Widget chatInput(BuildContext context, ChatbotState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        responsiveSize(context, 0.04, min: 16, max: 24),
        responsiveHeight(context, 0.012, min: 10, max: 14),
        responsiveSize(context, 0.04, min: 16, max: 24),
        responsiveHeight(context, 0.02, min: 14, max: 22),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: messageController,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 1,
              enabled: !state.isSending,
              onFieldSubmitted: (_) => _sendMessage(),
              style: const TextStyle(
                fontFamily: 'ArabicCustomFont',
                color: Color(0xFF4A2240),
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(
                  fontFamily: 'ArabicCustomFont',
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.04, min: 16, max: 22),
                  vertical: responsiveHeight(context, 0.018, min: 14, max: 18),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: responsiveSize(context, 0.025, min: 10, max: 14)),
          circleButton(
            icon: state.isSending
                ? Icons.hourglass_top_rounded
                : Icons.send_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF69B4), Color(0xFF8A2BE2)],
            ),
            onTap: state.isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget circleButton({
    required IconData icon,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A2BE2).withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class InteractiveBotCharacter extends StatefulWidget {
  final double responsiveSize;

  const InteractiveBotCharacter({super.key, required this.responsiveSize});

  @override
  State<InteractiveBotCharacter> createState() =>
      _InteractiveBotCharacterState();
}

class _InteractiveBotCharacterState extends State<InteractiveBotCharacter>
    with SingleTickerProviderStateMixin {
  bool _isHiMode = false;
  bool _showSupportBubble = false;
  Timer? _bubbleTimer;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final List<String> _supportMessages = [
    'قوتكِ تلهمنا جميعاً، نحن معكِ خطوة بخطوة 🌸',
    'أنتِ أقوى من أي تحدٍّ، رِفْق دائماً بجانبكِ 💕',
    'الابتسامة التي في عينيكِ هي أمل متجدد وعزيمة لا تقهر تذكري ذلك دائماً ✨',
    'كل يوم هو انتصار جديد لبطولتكِ الصامتة 🎀',
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.3),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));
  }

  void _handleTap() async {
    if (_slideController.isAnimating || _isHiMode) return;

    setState(() => _showSupportBubble = false);
    _bubbleTimer?.cancel();

    await _slideController.forward();

    if (mounted) {
      setState(() {
        _isHiMode = true;
        _currentMessageIndex =
            (_currentMessageIndex + 1) % _supportMessages.length;
      });
    }

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _slideController.reset();
    await _slideController.forward();

    if (mounted) setState(() => _showSupportBubble = true);

    _bubbleTimer = Timer(const Duration(milliseconds: 4500), () async {
      if (!mounted) return;
      setState(() => _showSupportBubble = false);

      _slideAnimation =
          Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0.0, 0.3),
          ).animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
          );

      _slideController.reset();
      await _slideController.forward();

      if (mounted) setState(() => _isHiMode = false);

      _slideAnimation =
          Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
          );

      _slideController.reset();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          opacity: _showSupportBubble ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(
              getScreenHeight(context) * 0.18 - widget.responsiveSize * 0.5,
              _showSupportBubble ? 0 : 5,
              0,
            ),
            margin: const EdgeInsets.only(bottom: 4, left: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: widget.responsiveSize * 1.3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: const Color(0xFFFFB6C1), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _supportMessages[_currentMessageIndex],
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'ArabicCustomFont',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2240),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _handleTap,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: widget.responsiveSize,
              height: widget.responsiveSize,
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                _isHiMode ? 'assets/bot/bot_hi_1.png' : 'assets/bot/bot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
