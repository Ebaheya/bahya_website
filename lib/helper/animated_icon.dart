import 'package:flutter/material.dart';

class HoverWaveAvatar extends StatefulWidget {
  final double radius;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? waveColor;
  final void Function()? onPressed;
  final IconData? icon;

  const HoverWaveAvatar({
    super.key,
    required this.radius,
    required this.iconColor,
    this.backgroundColor,
    this.waveColor,
    this.onPressed,
    this.icon,
  });

  @override
  State<HoverWaveAvatar> createState() => _HoverWaveAvatarState();
}

class _HoverWaveAvatarState extends State<HoverWaveAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? const Color(0xffEA4C89);
    final waveColor = widget.waveColor ?? bgColor;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1 + controller.value * 0.45,
              child: Container(
                width: widget.radius * 2,
                height: widget.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: waveColor.withOpacity(0.35 * (1 - controller.value)),
                    width: 3,
                  ),
                ),
              ),
            ),
            CircleAvatar(
              radius: widget.radius,
              backgroundColor: bgColor.withOpacity(0.14),
              child: CircleAvatar(
                radius: widget.radius * 0.78,
                backgroundColor: bgColor,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.onPressed,
                  icon: Icon(
                    widget.icon ?? Icons.person_rounded,
                    color: widget.iconColor,
                    size: widget.radius,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
