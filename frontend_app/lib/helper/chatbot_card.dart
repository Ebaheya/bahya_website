import 'dart:async';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:flutter/material.dart';

class ChatBotCard extends StatefulWidget {
  final double w;
  final double h;
  final VoidCallback onPressed;

  const ChatBotCard({
    super.key,
    required this.w,
    required this.h,
    required this.onPressed,
  });

  @override
  State<ChatBotCard> createState() => _ChatBotCardState();
}

class _ChatBotCardState extends State<ChatBotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _blinkTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _isBlinking = true;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _isBlinking = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.w * 0.92;
    final cardHeight =
        widget.h * 0.4; // الارتفاع الكلي لمنطقة الـ Stack ليعطي مساحة مريحة

    // 🛠️ هنا يمكنك التحكم في حجم الصورة (الروبوت) بالكامل
    // تعديل هذا الرقم (0.42) يغير العرض والارتفاع مئوياً ليظل متناسقاً (Responsive)
    final botSize = widget.w * 0.53;

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // ---------------- جسم الكارت الخلفي ----------------
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: widget.h * 0.05,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardWidth * 0.06,
                    vertical: widget.h * 0.02,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8A2BE2).withOpacity(0.15),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: Colors.white,
                          size: widget.w * 0.08,
                        ),
                      ),
                      SizedBox(height: widget.h * 0.01),
                      customText(
                        text: "محتاجه مساعده؟",
                        size: widget.w * 0.052,
                        color: Colors.white,
                      ),
                      SizedBox(height: widget.h * 0.005),
                      customText(
                        text: 'تواصلى مع الشات بوت الخاص بنا',
                        size: widget.w * 0.034,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------- الروبوت ----------------
              // 🛠️ هنا يمكنك ضبط مكان الصورة رأسيًا (ارتفاع الشخصية)
              // غيّر قيمة bottom (مثلا لـ 10 أو 20) لرفع الشخصية أو خفضها مقارنة بأسفل الكارت
              Positioned(
                bottom: widget.h * 0.0075,
                child: IgnorePointer(
                  child: SizedBox(
                    width:
                        botSize, // الحجم يتم التحكم به من المتغير المكتوب في الأعلى
                    height: botSize,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: Image.asset(
                        _isBlinking
                            ? 'assets/bot/bot_hands_up_blinks.png'
                            : 'assets/bot/bot_hands_up.png',
                        key: ValueKey<bool>(_isBlinking),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // ---------------- زر "تحدثى الان" ----------------
              // 🛠️ هنا يمكنك ضبط مكان الزر الأبيض تماماً ليلامس يد الروبوت المرفوعة
              // بزيادة هذا الرقم (مثلاً 0.05) يرتفع الزر للأعلى، وبتقليله ينزل للأسفل
              Positioned(
                bottom: widget.h * 0.175,
                left: cardWidth * 0.06,
                right: cardWidth * 0.06,
                child: CustomGlowButton(
                  title: "تحدثى الان",
                  onPressed: widget.onPressed,
                  width: widget.w * 0.8,
                  textSize: widget.w * 0.042,
                  height: widget.h * 0.058,
                  borderRadius: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
