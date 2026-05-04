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
  const CustomGlowButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.glowColor,
    this.textSize,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getScreenHeight(context) * 0.06,
      width: width ?? getScreenWidth(context) * 0.25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: glowColor ?? Color(0xFFFF7BB0).withOpacity(0.6),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: textColor ?? Color(0xFFFF7BB0),
          shape: const StadiumBorder(),
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
