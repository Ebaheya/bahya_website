import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/service/Login_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

Widget customText({
  required String text,
  required double size,
  bool isGradient = false,
  bool isEnglish = false,
  bool isCenter = true,
  Color? color,
  bool bold = true,
  TextAlign? align,
}) {
  return Text(
    text,
    textAlign: isCenter ? TextAlign.center : TextAlign.start,
    textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
    style: TextStyle(
      fontSize: size,
      fontFamily: 'ArabicCustomFont',
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: isGradient ? null : (color ?? Colors.black),
      foreground: isGradient
          ? (Paint()
              ..shader = LinearGradient(
                colors: [Color(0xFF8A2BE2), Color(0xFFFF69B4)],
              ).createShader(Rect.fromLTWH(0, 0, 200, 70)))
          : null,
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

PreferredSizeWidget customAppBar({
  required BuildContext context,
  required String title,
  bool isHomeBar = true,
  GlobalKey<ScaffoldState>? scaffoldKey,
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
                        GestureDetector(
                          onTap: () {
                            scaffoldKey?.currentState?.openDrawer();
                          },
                          child: CircleAvatar(
                            radius: h * 0.023,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.person,
                              color: Colors.pinkAccent,
                            ),
                          ),
                        ),
                        SizedBox(width: w * 0.02),
                        CustomGlowButton(
                          title: 'تسجيل الخروج',
                          onPressed: () async {
                            context.go('/login');
                            try {
                              await logout(
                                refreshToken:
                                    'c433f3b3282088a913d3281df978c801b9105268fb339fcfee640b45f9e61c71430a07bca0dcb403644ad5810abdd860307f753039253fa15c5de5da01871e79',
                              );
                              customDialog(
                                context: context,
                                title: 'تم',
                                message: 'تم تسجيل الخروج بنجاح.',
                              );
                            } catch (e) {
                              customDialog(
                                context: context,
                                title: 'خطأ',
                                message:
                                    'حدث خطأ أثناء تسجيل الخروج. حاول مرة أخرى.',
                              );
                            }
                          },
                          textSize: h * 0.015,
                          glowColor: Colors.white,
                          width: w * 0.25,
                          backgroundColor: Colors.white,
                          textColor: const Color(0xFF831843),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),

              Row(
                children: [
                  customText(
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
                  if (!isHomeBar)
                    IconButton(
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
              customText(
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
        customText(
          text: label,
          size: getScreenHeight(context) * 0.015,
          color: const Color(0xFF313131),
        ),
      ],
    );
  }
}

Widget pageHeader({
  required double width,
  required String title,
  String? subtitle,
  List<Widget>? widgets,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(colors: gradientColors),
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(text: title, size: width * 0.013, color: Colors.white),
            const SizedBox(height: 10),
            subtitle != null
                ? customText(
                    text: subtitle,
                    color: Colors.white54,
                    size: width * 0.01,
                  )
                : const SizedBox.shrink(),
          ],
        ),
        const Spacer(),
        if (widgets != null) ...widgets,
      ],
    ),
  );
}

