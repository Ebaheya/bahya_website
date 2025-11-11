import 'dart:developer';

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
  Icon? suffixIcon,
  bool obscureText = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: CustomFormTextField(
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      hintText: hintText,
      labelText: labelText,
      obscureText: obscureText,
      textDirection: TextDirection.ltr,
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

PreferredSizeWidget? homePageAppBar({required BuildContext context}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(getScreenHeight(context) * 0.1),
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
              Row(
                children: [
                  CircleAvatar(
                    radius: getScreenHeight(context) * 0.023,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.pinkAccent),
                  ),
                  SizedBox(width: getScreenWidth(context) * 0.02),
                  CustomGlowButton(
                    title: 'تسجيل الخروج',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    textSize: getScreenHeight(context) * 0.015,
                    glowColor: Colors.white,
                    width: getScreenWidth(context) * 0.25,
                    backgroundColor: Colors.white,
                    textColor: Color(0xFF831843),
                  ),
                ],
              ),
              Row(
                children: [
                  arabicText(
                    text: ' فريق الدعم النفسي',
                    size: getScreenHeight(context) * 0.02,
                    bold: true,
                    color: Color(0xFF831843),
                  ),
                  SizedBox(width: getScreenWidth(context) * 0.015),
                  CircleAvatar(
                    radius: getScreenHeight(context) * 0.02,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.pinkAccent,
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
