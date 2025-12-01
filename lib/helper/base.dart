import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget arabicText({
  required String text,
  required double size,
  bool isCenter = true,
  Color? color,
  bool bold = true,
  TextAlign? align,
}) {
  return Align(
    alignment: isCenter ? Alignment.center : Alignment.topRight,
    child: Text(
      textAlign: align ?? TextAlign.center,
      text,
      style: TextStyle(
        fontSize: size,
        fontFamily: 'ArabicCustomFont',
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
      textDirection: TextDirection.rtl,
    ),
  );
}

String webProxy(String url) =>
    'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}'; // CORS OK
Widget netImg(String url) {
  final proxied = kIsWeb ? webProxy(url) : url;
  return Image.network(
    proxied,
    width: 50,
    height: 50,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Image.asset(
      'assets/images/placeholder.png',
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    ),
  );
}

Widget buildTextField({
  required CustomTextFieldType keyboardType,
  required String hintText,
  required String labelText,
  int maxLines = 1,
  Icon? suffixIcon,
  bool obscureText = false,
  TextDirection textDirection = TextDirection.ltr,
  TextEditingController? controller,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: CustomFormTextField(
      controller: controller,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      hintText: hintText,
      labelText: labelText,
      obscureText: obscureText,
      textDirection: textDirection,
      maxLines: maxLines,
      suffixIcon: suffixIcon,
    ),
  );
}

Widget heartSign({
  Color colorSign = Colors.white,
  List<Color> gradientColors = const [Color(0xFFFF7BB0), Color(0xFFE6B3FF)],
  double containerSize = 90,
  double iconSize = 40,
}) {
  return Container(
    alignment: Alignment.center,
    width: containerSize,
    height: containerSize,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Icon(Icons.favorite_border, color: colorSign, size: iconSize),
  );
}

PreferredSizeWidget? customAppBar({
  required BuildContext context,
  bool isHomeBar = true,
  required String title,
}) {
  final h = getScreenHeight(context);
  final w = getScreenWidth(context);

  return PreferredSize(
    preferredSize: Size.fromHeight(h * 0.1),
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFfca5d6), Color(0xFFDBB1FF), Color(0xFFfca5d6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isHomeBar
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: h * 0.023,
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.person,
                            color: Colors.pinkAccent,
                          ),
                        ),
                        SizedBox(width: w * 0.02),
                        CustomGlowButton(
                          title: 'تسجيل الخروج',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          textSize: h * 0.015,
                          glowColor: Colors.white,
                          width: w * 0.25,
                          backgroundColor: Colors.white,
                          textColor: const Color(0xFF831843),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              Row(
                children: [
                  arabicText(
                    text: title,
                    size: h * 0.02,
                    bold: true,
                    color: const Color(0xFF831843),
                  ),
                  SizedBox(width: w * 0.015),
                  CircleAvatar(
                    radius: h * 0.02,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  isHomeBar
                      ? SizedBox.shrink()
                      : IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20,
                          ),
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

Widget sectionCard({
  required BuildContext context,
  required String title,
  required Widget child,
  IconData? trailingIcon,
  Gradient? gradient,
}) {
  return Container(
    width: getScreenWidth(context) * 0.95,
    margin: const EdgeInsets.only(bottom: 16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          spreadRadius: 1,
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          height: getScreenHeight(context) * 0.10,
          decoration: BoxDecoration(
            gradient:
                gradient ??
                const LinearGradient(
                  colors: [Color(0xFFfca5d6), Color(0xFFDBB1FF)],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              arabicText(
                text: title,
                size: getScreenHeight(context) * 0.02,
                bold: true,
                color: const Color(0xFF831843),
              ),
              const SizedBox(width: 10),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: Colors.white,
                  size: getScreenHeight(context) * 0.04,
                ),
            ],
          ),
        ),
        // المحتوى
        child,
      ],
    ),
  );
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        arabicText(
          text: label,
          size: getScreenHeight(context) * 0.015,
          color: const Color(0xFF313131),
        ),
      ],
    );
  }
}
