import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget arabicText({
  required String text,
  required double size,
  bool isCenter = true,
  Color? color,
  bool bold = true,
}) {
  return Align(
    alignment: isCenter ? Alignment.center : Alignment.topRight,
    child: Text(
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
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
    preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.1),
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
                    radius: MediaQuery.of(context).size.height * 0.023,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.pinkAccent),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  GestureDetector(
                    onTap: () {
                      print('Logout tapped');
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.04,
                      width: MediaQuery.of(context).size.width * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: arabicText(
                        text: 'تسجيل الخروج',
                        size: MediaQuery.of(context).size.height * 0.017,
                        bold: true,
                        color: Color(0xFF831843),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  arabicText(
                    text: ' فريق الدعم النفسي',
                    size: MediaQuery.of(context).size.height * 0.02,
                    bold: true,
                    color: Color(0xFF831843),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.height * 0.02,
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
