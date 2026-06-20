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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.w * 0.92;

    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: cardWidth,
          padding: EdgeInsets.symmetric(
            horizontal: cardWidth * 0.06,
            vertical: widget.h * 0.025,
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
            mainAxisSize: MainAxisSize.min,
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
              SizedBox(height: widget.h * 0.012),
              customText(
                text: 'محتاجه مساعده؟',
                size: widget.w * 0.052,
                color: Colors.white,
              ),
              SizedBox(height: widget.h * 0.006),
              customText(
                text: 'تواصلى مع الشات بوت الخاص بنا',
                size: widget.w * 0.034,
                color: Colors.white.withOpacity(0.9),
              ),
              SizedBox(height: widget.h * 0.022),
              CustomGlowButton(
                title: 'تحدثى الان',
                onPressed: widget.onPressed,
                width: double.infinity,
                textSize: widget.w * 0.042,
                height: widget.h * 0.058,
                borderRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
