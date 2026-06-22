import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedHomeBackground extends StatefulWidget {
  final Widget child;

  const AnimatedHomeBackground({super.key, required this.child});

  @override
  State<AnimatedHomeBackground> createState() => _AnimatedHomeBackgroundState();
}

class _AnimatedHomeBackgroundState extends State<AnimatedHomeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _HomeBackgroundPainter(_controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _HomeBackgroundPainter extends CustomPainter {
  final double value;

  _HomeBackgroundPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFFFFF6FB);
    canvas.drawRect(Offset.zero & size, paint);

    _drawBlob(
      canvas,
      size,
      Offset(
        size.width * (0.12 + sin(value * pi * 2) * 0.025),
        size.height * 0.18,
      ),
      180,
      const Color(0xFFE7549B).withValues(alpha: 0.10),
    );

    _drawBlob(
      canvas,
      size,
      Offset(
        size.width * (0.88 + cos(value * pi * 2) * 0.025),
        size.height * 0.10,
      ),
      220,
      const Color(0xFF8A2BE2).withValues(alpha: 0.10),
    );

    _drawBlob(
      canvas,
      size,
      Offset(
        size.width * (0.78 + sin(value * pi * 2) * 0.018),
        size.height * 0.78,
      ),
      260,
      const Color(0xFFFF5C9A).withValues(alpha: 0.07),
    );
  }

  void _drawBlob(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    Color color,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _HomeBackgroundPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
