import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
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
    final radiusValue =
        borderRadius ?? responsiveSize(context, 0.018, min: 14, max: 30);

    final radius = BorderRadius.circular(radiusValue);

    final buttonTextSize =
        textSize ?? responsiveSize(context, 0.009, min: 12, max: 16);

    final iconSize = responsiveSize(context, 0.012, min: 16, max: 22);

    final buttonHeight =
        height ?? responsiveHeight(context, 0.055, min: 40, max: 52);

    final buttonWidth =
        width ?? responsiveSize(context, 0.16, min: 130, max: 260);

    return Container(
      height: buttonHeight,
      width: buttonWidth,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: glowColor ?? const Color(0xFFFF7BB0).withOpacity(0.35),
            blurRadius: responsiveSize(context, 0.008, min: 8, max: 14),
            offset: Offset(0, responsiveHeight(context, 0.006, min: 3, max: 5)),
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
                    child: _ButtonContent(
                      title: title,
                      icon: icon,
                      textColor: textColor ?? Colors.white,
                      textSize: buttonTextSize,
                      iconSize: iconSize,
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
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.01, min: 12, max: 18),
                  vertical: responsiveHeight(context, 0.01, min: 8, max: 12),
                ),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: _ButtonContent(
                title: title,
                icon: icon,
                textColor: textColor ?? const Color(0xFFFF7BB0),
                textSize: buttonTextSize,
                iconSize: iconSize,
              ),
            ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color textColor;
  final double textSize;
  final double iconSize;

  const _ButtonContent({
    required this.title,
    required this.icon,
    required this.textColor,
    required this.textSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: iconSize),
              SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 10)),
            ],
            customText(
              text: title,
              size: textSize,
              bold: true,
              color: textColor,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
