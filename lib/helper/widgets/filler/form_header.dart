import 'dart:math' as math;
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class AnimatedPatientHeader extends StatefulWidget {
  final FormModel form;
  final int score;
  final String diagnosis;
  final String patientStatus;

  const AnimatedPatientHeader({
    super.key,
    required this.form,
    required this.score,
    required this.diagnosis,
    required this.patientStatus,
  });

  @override
  State<AnimatedPatientHeader> createState() => _AnimatedPatientHeaderState();
}

class _AnimatedPatientHeaderState extends State<AnimatedPatientHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool get _isMobile => MediaQuery.sizeOf(context).width < 700;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = responsiveSize(
      context,
      0.024,
      min: _isMobile ? 18 : 20,
      max: _isMobile ? 22 : 28,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFFCE4EC), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.04),
            blurRadius: _isMobile ? 16 : 24,
            offset: Offset(0, _isMobile ? 8 : 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(getScreenWidth(context), _isMobile ? 130 : 200),
                    painter: WavePainter(_controller.value),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: responsiveHeight(
                  context,
                  _isMobile ? 0.026 : 0.045,
                  min: _isMobile ? 18 : 28,
                  max: _isMobile ? 26 : 40,
                ),
                horizontal: responsiveSize(
                  context,
                  _isMobile ? 0.02 : 0.026,
                  min: _isMobile ? 12 : 16,
                  max: _isMobile ? 16 : 24,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mainIcon(),
                  SizedBox(
                    height: responsiveHeight(
                      context,
                      _isMobile ? 0.012 : 0.018,
                      min: 10,
                      max: 16,
                    ),
                  ),
                  _title(),
                  SizedBox(
                    height: responsiveHeight(context, 0.008, min: 6, max: 8),
                  ),
                  _subtitle(),
                  SizedBox(
                    height: responsiveHeight(
                      context,
                      _isMobile ? 0.022 : 0.035,
                      min: _isMobile ? 16 : 24,
                      max: _isMobile ? 22 : 34,
                    ),
                  ),
                  _infoCards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainIcon() {
    final size = responsiveSize(
      context,
      _isMobile ? 0.12 : 0.065,
      min: _isMobile ? 54 : 64,
      max: _isMobile ? 62 : 76,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF85B3).withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.description_rounded,
            color: const Color(0xFFFF2A85),
            size: responsiveSize(
              context,
              _isMobile ? 0.07 : 0.032,
              min: _isMobile ? 28 : 32,
              max: _isMobile ? 34 : 38,
            ),
          ),
          Positioned(
            bottom: responsiveSize(context, 0.012, min: 10, max: 15),
            right: responsiveSize(context, 0.012, min: 10, max: 15),
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user_rounded,
                color: const Color(0xFFFF2A85),
                size: responsiveSize(
                  context,
                  _isMobile ? 0.035 : 0.015,
                  min: 14,
                  max: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isMobile) _sparkleIcon(Icons.auto_awesome_rounded),
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.014, min: 8, max: 16),
            ),
            child: customText(
              text: widget.form.name,
              size: responsiveSize(
                context,
                _isMobile ? 0.07 : 0.024,
                min: _isMobile ? 24 : 28,
                max: _isMobile ? 30 : 36,
              ),
              bold: true,
              color: const Color(0xFF4A0033),
              isCenter: true,
              maxLines: 1,
            ),
          ),
        ),
        if (!_isMobile) _sparkleIcon(Icons.auto_awesome_rounded),
      ],
    );
  }

  Widget _subtitle() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(
          context,
          _isMobile ? 0.035 : 0.02,
          min: 14,
          max: 22,
        ),
        vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(100),
      ),
      child: customText(
        text: "اختر المريض ثم ابدأ الإجابات يدويًا",
        size: responsiveSize(
          context,
          _isMobile ? 0.032 : 0.011,
          min: 12,
          max: 15,
        ),
        color: const Color(0xFFFF2A85),
        bold: true,
        isCenter: true,
        maxLines: 2,
      ),
    );
  }

  Widget _infoCards() {
    final cards = [
      _infoCard(
        title: "التشخيص",
        value: widget.diagnosis,
        icon: Icons.person_add_alt_1_rounded,
        valueColor: const Color(0xFF7000FF),
      ),
      _infoCard(
        title: "الاسكور",
        value: widget.score.toString(),
        icon: Icons.bar_chart_rounded,
        valueColor: const Color(0xFF7000FF),
      ),
      _infoCard(
        title: "حالة المريض",
        value: widget.patientStatus,
        icon: Icons.shield_rounded,
        valueColor: const Color(0xFF7000FF),
      ),
    ];

    if (_isMobile) {
      return Column(
        children: [
          cards[0],
          SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
          cards[1],
          SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
          cards[2],
        ],
      );
    }

    return Wrap(
      spacing: responsiveSize(context, 0.02, min: 14, max: 20),
      runSpacing: responsiveHeight(context, 0.016, min: 12, max: 16),
      alignment: WrapAlignment.center,
      children: cards,
    );
  }

  Widget _sparkleIcon(IconData icon) {
    return Icon(
      icon,
      color: const Color(0xFFFF529E),
      size: responsiveSize(context, 0.016, min: 16, max: 20),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    final cardWidth = _isMobile
        ? double.infinity
        : responsiveSize(context, 0.16, min: 180, max: 230);

    final isAr = !RegExp(r'[a-zA-Z]').hasMatch(value);

    return Container(
      width: cardWidth,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(
          context,
          _isMobile ? 0.035 : 0.014,
          min: 12,
          max: 16,
        ),
        vertical: responsiveHeight(
          context,
          _isMobile ? 0.014 : 0.018,
          min: 12,
          max: 18,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 18),
        ),
        border: Border.all(color: const Color(0xFFF5F5F7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                customText(
                  text: title,
                  size: responsiveSize(
                    context,
                    _isMobile ? 0.03 : 0.0095,
                    min: 12,
                    max: 14,
                  ),
                  color: const Color(0xFF2D142C),
                  bold: true,
                  isEnglish: false,
                  isCenter: false,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.006, min: 4, max: 6),
                ),
                customText(
                  text: value,
                  size: responsiveSize(
                    context,
                    _isMobile ? 0.04 : 0.013,
                    min: 16,
                    max: 20,
                  ),
                  color: valueColor,
                  bold: true,
                  isEnglish: !isAr,
                  isCenter: false,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
          Container(
            width: responsiveSize(
              context,
              _isMobile ? 0.105 : 0.035,
              min: 38,
              max: 46,
            ),
            height: responsiveSize(
              context,
              _isMobile ? 0.105 : 0.035,
              min: 38,
              max: 46,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F6),
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 10, max: 12),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF2A85),
              size: responsiveSize(
                context,
                _isMobile ? 0.055 : 0.018,
                min: 20,
                max: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFE1F0).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    final phase1 = animationValue * 2 * math.pi;

    for (double i = 0; i <= size.width; i++) {
      final y = math.sin((i / size.width * 2 * math.pi) - phase1) * 10.0 + 30;
      path.lineTo(i, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final secondPaint = Paint()
      ..color = const Color(0xFFFFEDF6).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final secondPath = Path();
    secondPath.moveTo(0, size.height);

    final phase2 = animationValue * 2 * math.pi;

    for (double i = 0; i <= size.width; i++) {
      final y = math.cos((i / size.width * 2 * math.pi) - phase2) * 8.0 + 36;
      secondPath.lineTo(i, y);
    }

    secondPath.lineTo(size.width, size.height);
    secondPath.close();
    canvas.drawPath(secondPath, secondPaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
