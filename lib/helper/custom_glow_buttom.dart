import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class CustomGlowButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? glowColor;
  final double? textSize;
  final double? width;
  final double? height;
  final double? borderRadius;

  /// 👇 الجديد
  final bool isGradient;

  const CustomGlowButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.glowColor,
    this.textSize,
    this.width,
    this.height,
    this.borderRadius,

    /// 👇 الجديد
    this.isGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 30);

    return Container(
      height: height ?? getScreenHeight(context) * 0.06,
      width: width ?? getScreenWidth(context) * 0.25,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: glowColor ?? const Color(0xFFFF7BB0).withOpacity(0.6),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),

      /// 👇 لو Gradient
      child: isGradient
          ? ClipRRect(
              borderRadius: radius,
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: InkWell(
                    onTap: onPressed,
                    child: Center(
                      child: customText(
                        text: title,
                        size: textSize ?? getScreenHeight(context) * 0.02,
                        bold: true,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? Colors.white,
                foregroundColor: textColor ?? const Color(0xFFFF7BB0),
                shape: RoundedRectangleBorder(borderRadius: radius),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onPressed,
              child: customText(
                text: title,
                size: textSize ?? getScreenHeight(context) * 0.02,
                bold: true,
              ),
            ),
    );
  }
}
