import 'dart:async';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final botSize = responsiveSize(context, 0.45, min: 165, max: 210);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: customAppBar(
        title: "محادثة مع المساعد",
        subTitle: "أنا هنا لمساعدتك والإجابة على استفساراتك",
        isHome: false,
        context: context,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveSize(
                        context,
                        0.04,
                        min: 16,
                        max: 24,
                      ),
                      vertical: responsiveHeight(
                        context,
                        0.02,
                        min: 12,
                        max: 22,
                      ),
                    ),
                    child: Column(
                      children: [
                        botMessage(
                          context,
                          title: "مساعد رِفْق",
                          message:
                              "مرحباً 👋\nأنا مساعدك الذكي. يمكنك سؤالي عن الأعراض، العلاجات، المواعيد أو أي استفسار آخر.",
                          time: "07:20 PM",
                        ),
                        SizedBox(height: responsiveHeight(context, 0.025)),
                        userMessage(
                          context,
                          message:
                              "عندي ألم في الرأس من فترة، ما السبب وما الحل؟",
                          time: "07:21 PM",
                        ),
                        SizedBox(height: responsiveHeight(context, 0.025)),
                        botMessage(
                          context,
                          title: "مساعد رِفْق",
                          message:
                              "ألم الرأس قد يكون بسبب التوتر، قلة النوم أو الجفاف.\n\nأنصحك بـ:\n✓ شرب كمية كافية من الماء\n✓ أخذ قسط من الراحة\n✓ تجنب الشاشات لفترات طويلة\n\nإذا استمر الألم، يفضل استشارة الطبيب.",
                          time: "07:21 PM",
                        ),
                        // مساحة سفلية إضافية مريحة لتجنب تداخل السكرول مع الروبوت
                        SizedBox(height: responsiveHeight(context, 0.15)),
                      ],
                    ),
                  ),
                ),
                chatInput(context),
              ],
            ),

            Positioned(
              left: 0,
              bottom: getScreenHeight(context) * 0.4,
              child: InteractiveBotCharacter(responsiveSize: botSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: responsiveSize(context, 0.04, min: 16, max: 24),
        right: responsiveSize(context, 0.04, min: 16, max: 24),
        top: responsiveHeight(context, 0.025, min: 16, max: 26),
        bottom: responsiveHeight(context, 0.045, min: 28, max: 44),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF69B4), Color(0xFF8A2BE2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: responsiveSize(context, 0.12, min: 46, max: 58),
              height: responsiveSize(context, 0.12, min: 46, max: 58),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              customText(
                text: "محادثة مع المساعد",
                size: responsiveSize(context, 0.062, min: 23, max: 32),
                color: Colors.white,
                isCenter: false,
              ),
              SizedBox(height: responsiveHeight(context, 0.006)),
              customText(
                text: "أنا هنا لمساعدتك والإجابة على استفساراتك",
                size: responsiveSize(context, 0.035, min: 13, max: 18),
                color: Colors.white.withOpacity(0.9),
                bold: false,
                isCenter: false,
              ),
            ],
          ),
        ],
      ),
    );
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
                  text: "$time ✓✓",
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

  Widget chatInput(BuildContext context) {
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
          circleButton(
            icon: Icons.attach_file_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF8A2BE2), Color(0xFFFF69B4)],
            ),
          ),
          SizedBox(width: responsiveSize(context, 0.025, min: 10, max: 14)),
          Expanded(
            child: TextFormField(
              controller: messageController,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 1,
              style: const TextStyle(
                fontFamily: 'ArabicCustomFont',
                color: Color(0xFF4A2240),
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: "اكتب رسالتك هنا...",
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
            icon: Icons.send_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF69B4), Color(0xFF8A2BE2)],
            ),
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

  Widget customText({
    required String text,
    required double size,
    bool isGradient = false,
    bool isEnglish = false,
    bool isCenter = true,
    Color? color,
    bool bold = true,
    TextAlign? align,
    int maxLines = 1,
  }) {
    return Text(
      text,
      textAlign: align ?? (isCenter ? TextAlign.center : TextAlign.start),
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: size,
        fontFamily: 'ArabicCustomFont',
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: isGradient ? null : (color ?? const Color(0xFF4A2240)),
        foreground: isGradient
            ? (Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFF8A2BE2), Color(0xFFFF69B4)],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)))
            : null,
      ),
    );
  }
}

// --- الويدجيت المعدل: أنيميشن رأسي فائق السرعة وخاطف ---
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
    "قوتكِ تلهمنا جميعاً، نحن معكِ خطوة بخطوة 🌸",
    "أنتِ أقوى من أي تحدٍّ، رِفْق دائماً بجانبكِ 💕",
    "الابتسامة التي في عينيكِ هي أمل متجدد وعزيمة لا تقهر تذكري ذلك دائماً ✨",
    "كل يوم هو انتصار جديد لبطولتكِ الصامتة 🎀",
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 150,
      ), // تسريع الأنيميشن بشكل ملحوظ ليكون خاطفاً وفورياً
    );

    // حركة قصيرة ناعمة لأسفل
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.3),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));
  }

  void _handleTap() async {
    if (_slideController.isAnimating || _isHiMode) return;

    // 1. إخفاء فقاعة الكلام فوراً
    setState(() {
      _showSupportBubble = false;
    });
    _bubbleTimer?.cancel();

    // نزول سريع جداً لأسفل
    await _slideController.forward();

    // 2. تغيير الصورة والرسالة خلف الكواليس فوراً وهو بالأسفل
    if (mounted) {
      setState(() {
        _isHiMode = true;
        _currentMessageIndex =
            (_currentMessageIndex + 1) % _supportMessages.length;
      });
    }

    // 3. صعود سريع جداً مع ارتداد خفيف وممتع للاستقرار
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _slideController.reset();
    await _slideController.forward();

    // 4. إظهار فقاعة رسالة الدعم الجديدة
    if (mounted) {
      setState(() {
        _showSupportBubble = true;
      });
    }

    // 5. مؤقت للعودة للهيئة الطبيعية الأولى بعد 4.5 ثانية
    _bubbleTimer = Timer(const Duration(milliseconds: 4500), () async {
      if (mounted) {
        setState(() {
          _showSupportBubble = false;
        });

        // نزول سريع وخاطف
        _slideAnimation =
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(0.0, 0.3),
            ).animate(
              CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
            );

        _slideController.reset();
        await _slideController.forward();

        if (mounted) {
          setState(() {
            _isHiMode = false;
          });
        }

        // صعود فوري ومستقر للوضعية الافتراضية
        _slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
            );

        _slideController.reset();
        _slideController.forward();
      }
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
        // الفقاعة المنبثقة
        AnimatedOpacity(
          opacity: _showSupportBubble ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(
              0,
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

        // الروبوت التفاعلي بالسرعة الجديدة
        GestureDetector(
          onTap: _handleTap,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: widget.responsiveSize,
              height: widget.responsiveSize,
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                _isHiMode ? 'assets/bot/bot_hi.png' : 'assets/bot/bot.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
