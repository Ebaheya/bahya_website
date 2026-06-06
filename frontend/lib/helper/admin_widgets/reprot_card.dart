import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ReportCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final double value;

  const ReportCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool _hover = false;
  bool _pressed = false;

  void _setHover(bool v) => setState(() => _hover = v);
  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.98 : (_hover ? 1.04 : 1.0);
    final iconScale = _hover ? 1.15 : 1.0;

    final shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(_hover ? 0.12 : 0.06),
        blurRadius: _hover ? 28 : 10,
        offset: Offset(0, _hover ? 14 : 4),
      ),
    ];

    final bgColor = _hover ? Colors.grey[50] : Colors.white;

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),

        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: shadow,
            ),

            child: Row(
              children: [
                /// Icon
                AnimatedScale(
                  scale: iconScale,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: getScreenWidth(context) * 0.02,
                    ),
                  ),
                ),

                SizedBox(width: getScreenWidth(context) * 0.01),

                /// Title
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customText(
                      text: widget.title,
                      size: getScreenWidth(context) * 0.009,
                      color: Colors.grey,
                      isEnglish: true,
                    ),

                    SizedBox(height: getScreenHeight(context) * 0.001),

                    /// Value
                    customText(
                      text: widget.value.toString(),
                      size: getScreenWidth(context) * 0.009,
                      color: const Color(0xFF8B2C00),
                      bold: true,
                      isEnglish: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
