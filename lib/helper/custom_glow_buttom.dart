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
  final bool isGradient;
  final IconData? icon;

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
    this.isGradient = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 30);

    final buttonTextSize = textSize ?? getScreenWidth(context) * 0.01;

    final iconSize = textSize ?? getScreenWidth(context) * 0.015;

    return Container(
      height: height ?? getScreenHeight(context) * 0.05,
      width: width ?? getScreenWidth(context) * 0.2,

      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: glowColor ?? const Color(0xFFFF7BB0).withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

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
                    borderRadius: radius,
                    onTap: onPressed,

                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        mainAxisSize: MainAxisSize.min,

                        children: [
                           if (icon != null) ...[
                        
                            Icon(
                              icon,
                              color: textColor ?? Colors.white,
                              size: iconSize,
                            ),
                                const SizedBox(width: 10),
                          ],
                          customText(
                            text: title,
                            size: buttonTextSize,
                            bold: true,
                            color: textColor ?? Colors.white,
                          ),
                         
                        ],
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

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                mainAxisSize: MainAxisSize.min,

                children: [
                  if (icon != null) ...[
                  
                    Icon(
                      icon,
                      color: textColor ?? const Color(0xFFFF7BB0),

                      size: iconSize,
                    ),
                      const SizedBox(width: 10),
                  ],
                  customText(
                    text: title,
                    size: buttonTextSize,
                    bold: true,
                    color: textColor ?? const Color(0xFFFF7BB0),
                  ),
                  
                ],
              ),
            ),
    );
  }
}
