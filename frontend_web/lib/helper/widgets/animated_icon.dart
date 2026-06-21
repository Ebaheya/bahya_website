import 'package:flutter/material.dart';

class HoverWaveAvatar extends StatefulWidget {
  final double radius;
  final Color iconColor;
  final void Function()? onPressed;
  final IconData? icon;

  const HoverWaveAvatar({
    super.key,
    required this.radius,
    required this.iconColor,
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1 + controller.value * 0.55,
              child: Container(
                width: widget.radius * 2,
                height: widget.radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.iconColor.withOpacity(1 - controller.value),
                    width: 3,
                  ),
                ),
              ),
            ),

            Transform.scale(
              scale: 1 + (controller.value * 0.04),
              child: CircleAvatar(
                radius: widget.radius,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: CircleAvatar(
                  radius: widget.radius * 0.78,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: widget.onPressed,
                    icon: Icon(
                      widget.icon ?? Icons.person_rounded,
                      color: widget.iconColor,
                      size: widget.radius,
                    ),
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
