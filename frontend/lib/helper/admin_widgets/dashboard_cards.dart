import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final double? percentage;
  final bool hasPercentage;
  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
     this.percentage,
     this.hasPercentage = true,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _hover = false;
  bool _pressed = false;

  void _setHover(bool v) => setState(() => _hover = v);
  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final bool isPositive = widget.percentage != null && widget.percentage! >= 0;

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

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Icon
                    AnimatedScale(
                      scale: iconScale,
                      duration: const Duration(milliseconds: 180),
                      child: Container(
                        padding: const EdgeInsets.all(8),
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

                    /// Percentage
                    widget.hasPercentage ? 
                    customText(
                      text:
                          "${isPositive ? "+" : ""}${widget.percentage?.toStringAsFixed(1)}%",
                      size: getScreenWidth(context) * 0.01,
                      color: isPositive ? Colors.green : Colors.red,
                      bold: true,
                      isEnglish: true,
                    )
                    : const SizedBox.shrink(),
                  ],
                ),

                SizedBox(height: getScreenHeight(context) * 0.01),

                /// Title
                customText(
                  text: widget.title,
                  size: getScreenWidth(context) * 0.01,
                  color: Colors.grey,
                  isEnglish: true,
                ),

                SizedBox(height: getScreenHeight(context) * 0.01),

                /// Value
                customText(
                  text: widget.value,
                  size: getScreenWidth(context) * 0.01,
                  color: const Color(0xFF8B2C00),
                  bold: true,
                  isEnglish: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
