import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
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
  int maxLines = 1,
}) {
  return Text(
    text,
    textAlign: isCenter ? TextAlign.center : TextAlign.start,
    textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
    maxLines: maxLines,
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
  String? labelText,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
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
                        IconButton(
                          onPressed: () {
                            scaffoldKey?.currentState?.openDrawer();
                          },
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     scaffoldKey?.currentState?.openDrawer();
                        //   },
                        //   child: const Icon(
                        //     Icons.menu,
                        //     color: Colors.white,
                        //     size: 28,
                        //   ),
                        //   // child: CircleAvatar(
                        //   //   radius: h * 0.023,
                        //   //   backgroundColor: Colors.white,
                        //   //   child: const Icon(
                        //   //     Icons.person,
                        //   //     color: Colors.pinkAccent,
                        //   //   ),
                        //   // ),
                        // ),
                        SizedBox(width: w * 0.02),
                      ],
                    )
                  : SizedBox.shrink(),

              Row(
                children: [
                  customText(
                    text: title,
                    size: h * 0.02,
                    bold: true,
                    color: Colors.white,
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
                  onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
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
  bool? isShadow = true,
}) {
  return Container(
    width: getScreenWidth(context) * 0.95,
    margin: const EdgeInsets.only(bottom: 16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        isShadow == true
            ? BoxShadow(
                color: Colors.black26,
                spreadRadius: 1,
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            : const BoxShadow(
                color: Colors.transparent,
                spreadRadius: 0,
                blurRadius: 0,
                offset: Offset(0, 0),
              ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          height: getScreenHeight(context) * 0.10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
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
                color: Colors.white,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
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
  required double height,
  required String title,
  required IconData? icon,
  String? subtitle,
  List<Widget>? widgets,
}) {
  return Container(
    width: double.infinity,
    height: height * 0.15,
   
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withOpacity(0.18),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child:  Icon(
              icon,
              color: Colors.white,
              size: 34,
            ),
          ),
    
          const SizedBox(width: 22),
    
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customText(
                text: title,
                size: width * 0.017,
                color: Colors.white,
                bold: true,
                isEnglish: true,
              ),
              const SizedBox(height: 10),
              if (subtitle != null)
                customText(
                  text: subtitle,
                  color: Colors.white.withOpacity(0.75),
                  size: width * 0.01,
                  isEnglish: true,
                ),
            ],
          ),
    
          const Spacer(),
    
          if (widgets != null) ...widgets,
        ],
      ),
    ),
  );
}

Widget customLoading() {
  return Padding(
    padding: const EdgeInsets.all(20),

    child: Center(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1),

          duration: const Duration(milliseconds: 5000),

          curve: Curves.easeInOut,

          builder: (context, value, child) {
            return Transform.scale(
              scale: value,

              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(colors: gradientColors),

                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.35),

                      blurRadius: 25,

                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: const SizedBox(
                  width: 40,

                  height: 40,

                  child: CircularProgressIndicator(
                    strokeWidth: 5,

                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),

                    backgroundColor: Colors.white24,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> customSnackBar({
  required BuildContext context,
  required String message,
}) {
  final w = getScreenWidth(context);
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: buttonColor,
      animation: const AlwaysStoppedAnimation(1),
      showCloseIcon: true,
      content: customText(
        isCenter: true,
        text: message,
        size: w * 0.01,
        color: Colors.white,
      ),
    ),
  );
}

Widget modernInputBox({required IconData icon, required Widget child}) {
  return Container(
    height: 62,
    padding: const EdgeInsets.only(left: 14, right: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.withOpacity(0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 14,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: buttonColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: buttonColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    ),
  );
}
