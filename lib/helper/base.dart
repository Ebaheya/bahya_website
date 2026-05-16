import 'dart:ui';

import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/screens/patients/profile.dart';
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
      color: isGradient ? null : (color ?? textColor),
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
  required String subTitle,
  IconData? icon,
  GlobalKey<ScaffoldState>? scaffoldKey,
  isHome = true,
  void Function()? onIconPressed,
  List<Widget>? widgets,
  Size? preferredSize,
}) {
  final h = getScreenHeight(context);
  final w = getScreenWidth(context);

  return PreferredSize(
    preferredSize: preferredSize ?? Size.fromHeight(h * 0.1),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (icon == null && isHome == false)
                      ? SizedBox.shrink()
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              isHome
                                  ? showGeneralDialog(
                                      context: context,
                                      barrierLabel: "Profile",
                                      barrierDismissible: true,
                                      barrierColor: Colors.black.withOpacity(
                                        0.2,
                                      ),
                                      transitionDuration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) {
                                            return const Profile();
                                          },
                                      transitionBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            final curvedAnimation =
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOutBack,
                                                );

                                            return BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 8,
                                                sigmaY: 8,
                                              ),
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin: const Offset(0, 0.25),
                                                  end: Offset.zero,
                                                ).animate(curvedAnimation),
                                                child: FadeTransition(
                                                  opacity: curvedAnimation,
                                                  child: child,
                                                ),
                                              ),
                                            );
                                          },
                                    )
                                  : onIconPressed != null
                                  ? onIconPressed()
                                  : null;
                            },
                            icon: Icon(
                              isHome ? Icons.person_2_outlined : icon,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customText(
                            text: title,
                            size: w * 0.05,
                            bold: true,
                            color: Colors.white,
                          ),
                          customText(
                            text: subTitle,
                            size: w * 0.03,
                            bold: true,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      isHome
                          ? SizedBox.shrink()
                          : widgets != null
                          ? SizedBox.shrink()
                          : Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: h * 0.02),
              if (widgets != null) ...widgets,
            ],
          ),
        ),
      ),
    ),
  );
}

Widget chatBotCard({required double w, required double h}) {
  return Center(
    child: Column(
      children: [
        SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
            gradient: LinearGradient(colors: gradientColors),
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.chat, color: Colors.white, size: w * 0.1),
                  ),
                  Column(
                    children: [
                      customText(
                        text: "محتاجه مساعده؟",
                        size: w * 0.05,
                        color: Colors.white,
                      ),
                      customText(
                        text: 'تواصلى مع الشات بوت الخاص بنا',
                        size: w * 0.03,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              CustomGlowButton(
                title: "تحدثى الان",
                onPressed: () {},
                width: w * 0.8,
                textSize: w * 0.04,
                height: h * 0.06,
                borderRadius: 12,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget serviceCard({
  required String title,
  required String description,
  required VoidCallback onTap,
  required double w,
  required double h,
  required IconData icon,
  required Color primaryColor,
  required Color secondaryColor,
  required Color buttonColor,
  required Color? salesBackgroundColor,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 5,
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(icon, size: w * 0.1, color: secondaryColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(text: title, size: w * 0.04, bold: true),
            customText(text: description, size: w * 0.03, color: Colors.grey),
          ],
        ),
        Spacer(),
        CustomGlowButton(
          title: "انضمى الان",
          onPressed: onTap,
          width: w * 0.2,
          height: h * 0.05,
          textSize: w * 0.025,
          backgroundColor: buttonColor,
          textColor: Colors.white,
          glowColor: salesBackgroundColor,
        ),
      ],
    ),
  );
}

Widget serviceInfo({
  required double w,
  required double h,
  required String title,
  required String date,
  required String time,
  required String location,
  double? availableSeats,
  bool isCompleted = false,
  bool isUnderReview = false,
  bool isSupport = false,
  String? meetingPlace,
  bool isTravel = false,
  bool isRequested = false,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                isRequested
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isTravel
                              ? Colors.blue[100]!
                              : (isSupport
                                    ? Colors.purple[100]!
                                    : Colors.green[100]!),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          isTravel
                              ? Icons.directions_bus_rounded
                              : (isSupport
                                    ? Icons.groups_rounded
                                    : Icons.menu_book_rounded),
                          size: w * 0.1,
                          color: isTravel
                              ? Colors.blue[400]!
                              : (isSupport
                                    ? Colors.purple[400]!
                                    : Colors.green[400]!),
                        ),
                      )
                    : SizedBox.shrink(),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    customText(text: title, size: w * 0.04),
                    SizedBox(height: h * 0.01),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        customText(
                          text: isTravel
                              ? 'موعد الانطلاق: $date'
                              : 'التاريخ: $date',
                          size: w * 0.035,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.01),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        customText(
                          text: isTravel ? 'المده: $time' : 'الوقت: $time',
                          size: w * 0.035,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.01),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        customText(
                          text: isTravel
                              ? "المكان: $location"
                              : "الفرع: $location",
                          size: w * 0.035,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.01),
                    isTravel
                        ? Row(
                            children: [
                              Icon(
                                Icons.directions_bus,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              customText(
                                text: "موقع التجمع: $meetingPlace",
                                size: w * 0.035,
                                color: Colors.grey[600],
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
            SizedBox(height: h * 0.02),
            isRequested
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green[100]!
                          : (isUnderReview
                                ? Colors.orange[100]!
                                : Colors.red[100]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: customText(
                      text: isCompleted
                          ? "تمت الموافقة على طلبك"
                          : (isUnderReview
                                ? "طلبك قيد المراجعة"
                                : "تم رفض طلبك"),
                      size: w * 0.035,
                      color: isCompleted
                          ? Colors.green[800]
                          : (isUnderReview
                                ? Colors.orange[800]
                                : Colors.red[800]!),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isTravel
                          ? Colors.blue[100]!
                          : (isSupport
                                ? Colors.purple[100]!
                                : Colors.green[100]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: customText(
                      text: "متاح $availableSeats مقعد",
                      size: w * 0.035,
                      color: isTravel
                          ? Colors.blue[800]
                          : (isSupport
                                ? Colors.purple[800]
                                : Colors.green[800]),
                    ),
                  ),
            SizedBox(height: h * 0.01),
            isRequested
                ? SizedBox.shrink()
                : CustomGlowButton(
                    title: "انضمام",
                    width: double.infinity,
                    height: h * 0.05,
                    textSize: w * 0.035,
                    glowColor: isTravel
                        ? Colors.blue[300]!
                        : (isSupport
                              ? Colors.purple[300]!
                              : Colors.green[300]!),
                    backgroundColor: isTravel
                        ? Colors.blue
                        : (isSupport ? Colors.purple : Colors.green),
                    textColor: Colors.white,
                    borderRadius: 8,
                    onPressed: () {},
                  ),
          ],
        ),
      ),
    ),
  );
}

Widget requestedState({required double w, required double h}) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 7,
          offset: const Offset(0, 0),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: w * 0.1,
              height: h * 0.035,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            customText(text: 'الحاله الإجمالية', size: w * 0.04),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: h * 0.1,
              width: w * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 7,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customText(text: "2", size: w * 0.05, color: Colors.green),
                  SizedBox(height: 10),
                  customText(
                    text: "مقبولة",
                    size: w * 0.04,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
            Container(
              height: h * 0.1,
              width: w * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 7,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customText(text: "1", size: w * 0.05, color: Colors.grey),
                  SizedBox(height: 10),
                  customText(
                    text: "في الانتظار",
                    size: w * 0.04,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

Widget adminStateCards({required double w, required double h}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Container(
        width: w * 0.25,
        height: h * 0.18,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.av_timer_rounded, color: Colors.white, size: w * 0.06),
            SizedBox(height: 4),
            customText(text: '4', size: w * 0.035, color: Colors.white),
            SizedBox(height: 4),
            SizedBox(
              width: w * 0.17,
              child: customText(
                text: 'طلبات قيد المراجعة',
                size: w * 0.035,
                maxLines: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      Container(
        width: w * 0.25,
        height: h * 0.18,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person_add_alt_rounded,
              color: Colors.white,
              size: w * 0.06,
            ),
            SizedBox(height: 4),
            customText(text: '4', size: w * 0.035, color: Colors.white),
            SizedBox(height: 4),
            SizedBox(
              width: w * 0.17,
              child: customText(
                text: 'انضمامات جديدة اليوم',
                size: w * 0.035,
                maxLines: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      Container(
        width: w * 0.25,
        height: h * 0.18,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: w * 0.06),
            SizedBox(height: 4),
            customText(text: '4', size: w * 0.035, color: Colors.white),
            SizedBox(height: 4),
            SizedBox(
              width: w * 0.17,
              child: customText(
                text: 'طلبات تمت الموافقة عليها',
                size: w * 0.035,
                maxLines: 3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
