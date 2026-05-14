import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:flutter/material.dart';


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
                  : const SizedBox.shrink(),

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
