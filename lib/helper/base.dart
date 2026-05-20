import 'dart:ui';

import 'package:bahya_app/helper/custom_date_picker.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/custom_time_picker.dart';
import 'package:bahya_app/helper/filter_dropdown.dart';
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
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      height: h * 0.24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: h * 0.065,
            width: h * 0.065,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: secondaryColor, size: w * 0.065),
          ),

          SizedBox(height: h * 0.015),

          customText(
            text: title,
            size: w * 0.032,
            bold: true,
            isCenter: true,
            maxLines: 2,
          ),

          SizedBox(height: h * 0.008),

          Expanded(
            child: customText(
              text: description,
              size: w * 0.026,
              color: Colors.grey,
              isCenter: true,
              maxLines: 3,
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: h * 0.035,
              width: h * 0.035,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: buttonColor,
                size: w * 0.03,
              ),
            ),
          ),
        ],
      ),
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
  bool forAdmin = false,
  double? availableSeats,
  bool isAccepted = false,
  bool isUnderReview = false,
  bool isSupport = false,
  String? meetingPlace,
  bool isTravel = false,
  bool isRequested = false,
}) {
  final Color mainColor = isTravel
      ? Colors.blue[600]!
      : (isSupport ? Colors.purple[600]! : Colors.green[700]!);

  final Color lightColor = isTravel
      ? Colors.blue[50]!
      : (isSupport ? Colors.purple[50]! : Colors.green[50]!);

  final IconData mainIcon = isTravel
      ? Icons.directions_bus_rounded
      : (isSupport ? Icons.groups_rounded : Icons.menu_book_rounded);

  Widget infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: h * 0.01),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: h * 0.035,
            height: h * 0.035,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: mainColor, size: w * 0.04),
          ),
          SizedBox(width: w * 0.025),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      fontSize: w * 0.036,
                      color: Colors.grey[700],
                      fontFamily: 'ArabicCustomFont',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: w * 0.035,
                      color: mainColor,
                      fontFamily: 'ArabicCustomFont',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: h * 0.075,
                    height: h * 0.075,
                    decoration: BoxDecoration(
                      color: lightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(mainIcon, color: mainColor, size: w * 0.075),
                  ),
                  // Positioned(
                  //   top: -3,
                  //   right: -3,
                  //   child: Container(
                  //     width: h * 0.027,
                  //     height: h * 0.027,
                  //     decoration: BoxDecoration(
                  //       color: mainColor,
                  //       shape: BoxShape.circle,
                  //       border: Border.all(color: Colors.white, width: 2),
                  //     ),
                  //     child: Icon(
                  //       Icons.star_rounded,
                  //       color: Colors.white,
                  //       size: w * 0.03,
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              Expanded(
                child: customText(
                  text: title,
                  size: w * 0.043,
                  bold: true,
                  color: const Color(0xff14213D),
                  maxLines: 2,
                ),
              ),
              forAdmin
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAccepted
                            ? Colors.green[50]
                            : (isUnderReview
                                  ? Colors.orange[50]
                                  : Colors.red[50]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: customText(
                        text: isAccepted
                            ? "تمت الموافقة على طلبك"
                            : (isUnderReview
                                  ? "طلبك قيد المراجعة"
                                  : "تم رفض طلبك"),
                        size: w * 0.03,
                        color: isAccepted
                            ? Colors.green[800]
                            : (isUnderReview
                                  ? Colors.orange[800]
                                  : Colors.red[800]),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),

          SizedBox(height: h * 0.02),

          infoRow(
            icon: Icons.calendar_month_rounded,
            title: isTravel ? 'موعد الانطلاق: ' : 'التاريخ: ',
            value: date,
          ),

          infoRow(
            icon: Icons.access_time_rounded,
            title: isTravel ? 'المده: ' : 'الوقت: ',
            value: time,
          ),

          infoRow(
            icon: Icons.location_on_rounded,
            title: isTravel ? "المكان: " : "الفرع: ",
            value: location,
          ),

          if (isTravel)
            infoRow(
              icon: Icons.directions_bus_rounded,
              title: "موقع التجمع: ",
              value: meetingPlace ?? "غير محدد",
            ),

          !forAdmin
              ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: h * 0.008),
                      child: Divider(
                        color: Colors.grey.withOpacity(0.25),
                        thickness: 1,
                        height: 1,
                      ),
                    ),

                    SizedBox(height: h * 0.012),
                  ],
                )
              : const SizedBox.shrink(),

          isRequested && !forAdmin
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  //Accepted: green, Under review: orange, Rejected: red
                  decoration: BoxDecoration(
                    color: isAccepted
                        ? Colors.green[50]
                        : (isUnderReview ? Colors.orange[50] : Colors.red[50]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: customText(
                    text: isAccepted
                        ? "تمت الموافقة على طلبك"
                        : (isUnderReview ? "طلبك قيد المراجعة" : "تم رفض طلبك"),
                    size: w * 0.033,
                    color: isAccepted
                        ? Colors.green[800]
                        : (isUnderReview
                              ? Colors.orange[800]
                              : Colors.red[800]),
                  ),
                )
              : forAdmin
              ? SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        color: mainColor,
                        size: w * 0.045,
                      ),
                      Expanded(
                        child: customText(
                          text: "متاح $availableSeats مقعد",
                          size: w * 0.033,
                          color: mainColor,
                          bold: true,
                        ),
                      ),
                    ],
                  ),
                ),

          SizedBox(height: h * 0.012),

          isRequested || forAdmin
              ? const SizedBox.shrink()
              : CustomGlowButton(
                  title: "الانضمام الآن",
                  width: double.infinity,
                  height: h * 0.052,
                  textSize: w * 0.035,
                  glowColor: mainColor.withOpacity(0.45),
                  backgroundColor: mainColor,
                  textColor: Colors.white,
                  borderRadius: 10,
                  onPressed: () {},
                ),
        ],
      ),
    ),
  );
}

Widget requestedState({required double w, required double h}) {
  Widget stateBox({
    required String count,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: h * 0.17,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: h * 0.055,
              width: h * 0.055,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: w * 0.07),
            ),

            SizedBox(height: h * 0.012),

            customText(text: count, size: w * 0.06, color: color, bold: true),

            SizedBox(height: h * 0.004),

            customText(text: title, size: w * 0.035, color: color, bold: true),

            SizedBox(height: h * 0.01),

            Container(
              height: 4,
              width: w * 0.07,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.purple.withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            customText(
              text: 'الحاله الإجمالية',
              size: w * 0.045,
              bold: true,
              color: const Color(0xff14213D),
            ),
            const Spacer(),
            Container(
              height: h * 0.045,
              width: h * 0.045,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.trending_up_rounded, color: Colors.white),
            ),
          ],
        ),

        SizedBox(height: h * 0.025),

        Row(
          children: [
            stateBox(
              count: "1",
              title: "مرفوض",
              icon: Icons.close_rounded,
              color: Colors.pink,
            ),
            stateBox(
              count: "1",
              title: "في الانتظار",
              icon: Icons.access_time_rounded,
              color: Colors.deepPurple,
            ),
            stateBox(
              count: "2",
              title: "مقبولة",
              icon: Icons.check_circle_outline_rounded,
              color: Colors.green,
            ),
          ],
        ),
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
            Icon(Icons.av_timer_rounded, color: Colors.white, size: w * 0.08),
            SizedBox(height: 4),
            customText(text: '4', size: w * 0.07, color: Colors.white),
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
              size: w * 0.08,
            ),
            SizedBox(height: 4),
            customText(text: '4', size: w * 0.07, color: Colors.white),
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
            Icon(Icons.check_circle, color: Colors.white, size: w * 0.08),
            SizedBox(height: 4),
            customText(text: '4', size: w * 0.07, color: Colors.white),
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

Widget serviceAddForm({
  required BuildContext context,
  required TextEditingController timeController,
  required bool isTravel,
  required Function(String) onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),

          blurRadius: 1,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        FilterDropdown(
          borderRadius: BorderRadius.circular(8),
          hint: "اختر نوع الخدمه",
          items: const [
            "خدمات تعليميه",
            "رحلات و نزهات",
            "مجموعات الدعم النفسي",
          ],
          onChanged: (onChanged),
        ),
        SizedBox(height: 15),
        CustomFormTextField(
          hintText: "اسم الخدمه مثال: محو الاميه  المستوى الاول",
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: CustomTextFieldType.text,

          borderRadius: 8,
        ),
        SizedBox(height: 15),
        Row(
          children: [
            SizedBox(
              width: getScreenWidth(context) * 0.37,
              child: CustomDatePickerField(
                hintText: isTravel ? "تاريخ البدايه" : "تاريخ الخدمه",
                controller: TextEditingController(),
                borderRadius: 8,
              ),
            ),
            const Spacer(),

            SizedBox(
              width: getScreenWidth(context) * 0.37,
              child: CustomTimePickerField(
                borderRadius: 8,
                labelText: "الوقت",
                hintText: "-- : --",
                controller: timeController,
                onTimeSelected: (time) {
                  print(time.format(context));
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(opacity: animation, child: child),
            );
          },

          child: isTravel
              ? Column(
                  key: const ValueKey("travelFields"),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CustomDatePickerField(
                        hintText: "تاريخ النهايه",
                        controller: TextEditingController(),
                        borderRadius: 8,
                      ),
                    ),

                    SizedBox(height: 15),

                    CustomFormTextField(
                      hintText: "مكان التجمع : مثال: الرياض - حي النخيل",
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: CustomTextFieldType.text,
                      borderRadius: 8,
                    ),

                    SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: CustomTimePickerField(
                        borderRadius: 8,
                        labelText: "وقت الانطلاق",
                        hintText: "-- : --",
                        controller: timeController,
                        onTimeSelected: (time) {
                          print(time.format(context));
                        },
                      ),
                    ),

                    SizedBox(height: 15),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        CustomFormTextField(
          hintText: "الموقع او الفرع : مثال: الرياض - حي النخيل",
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: CustomTextFieldType.text,

          borderRadius: 8,
        ),
        SizedBox(height: 15),
        CustomFormTextField(
          hintText: "عدد المقاعد المتوفره : مثال: 10 مقاعد",
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: CustomTextFieldType.text,

          borderRadius: 8,
        ),
        SizedBox(height: 15),
        CustomGlowButton(
          width: double.infinity,
          borderRadius: 12,
          title: "اضافة الخدمه",
          onPressed: () {},
          isGradient: true,
        ),
      ],
    ),
  );
}

Widget requestedServiceCard({
  required double w,
  required double h,
  required String nameOfPatient,
  required String medicalNumber,
  required String service,
  required String requestDate,
  bool isTravel = false,
  bool isSupport = false,
}) {
  final Color primaryColor = isTravel
      ? Colors.blue[400]!
      : (isSupport ? Colors.purple[400]! : Colors.green[400]!);

  final Color secondaryColor = isTravel
      ? Colors.blue[100]!
      : (isSupport ? Colors.purple[100]! : Colors.green[100]!);

  final IconData serviceIcon = isTravel
      ? Icons.directions_bus_rounded
      : (isSupport ? Icons.groups_rounded : Icons.menu_book_rounded);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: h * 0.12,
              width: w * 0.22,
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.35),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(serviceIcon, color: primaryColor, size: w * 0.1),
            ),

            SizedBox(width: w * 0.03),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: nameOfPatient,
                    size: w * 0.045,
                    color: const Color(0xff7A004C),
                  ),

                  SizedBox(height: h * 0.004),

                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "الرقم الطبي : ",
                          style: TextStyle(
                            fontSize: w * 0.036,
                            color: Colors.grey[700],
                            fontFamily: 'ArabicCustomFont',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: medicalNumber,
                          style: TextStyle(
                            fontSize: w * 0.035,
                            color: const Color(0xffEA4C89),
                            fontFamily: 'ArabicCustomFont',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h * 0.015),

                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xffFDF4FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xffFF69A6).withOpacity(0.25),
                      ),
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RichText(
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "الخدمه: ",
                                      style: TextStyle(
                                        fontSize: w * 0.035,
                                        color: Colors.grey[700],
                                        fontFamily: 'ArabicCustomFont',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: service,
                                      style: TextStyle(
                                        fontSize: w * 0.035,
                                        color: const Color(0xffEA4C89),
                                        fontFamily: 'ArabicCustomFont',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: h * 0.012,
                                ),
                                child: Container(
                                  height: 1.2,
                                  width: double.infinity,
                                  color: Colors.pink.withOpacity(0.25),
                                ),
                              ),

                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.deepPurpleAccent,
                                    size: w * 0.05,
                                  ),

                                  SizedBox(width: w * 0.02),

                                  Expanded(
                                    child: RichText(
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "تاريخ الطلب: ",
                                            style: TextStyle(
                                              fontSize: w * 0.034,
                                              color: Colors.grey[700],
                                              fontFamily: 'ArabicCustomFont',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text: requestDate,
                                            style: TextStyle(
                                              fontSize: w * 0.034,
                                              color: const Color(0xffEA4C89),
                                              fontFamily: 'ArabicCustomFont',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: w * 0.03),

                        Center(
                          child: Container(
                            height: h * 0.055,
                            width: h * 0.055,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xffFF69A6).withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.workspace_premium_outlined,
                              color: const Color(0xffEA4C89),
                              size: w * 0.065,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: h * 0.03),

        Row(
          children: [
            Expanded(
              child: Container(
                height: h * 0.055,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff8E2DE2), Color(0xffFF4F9A)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),

                        SizedBox(width: w * 0.02),

                        customText(
                          text: "قبول الطلب",
                          size: w * 0.04,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: w * 0.04),

            Expanded(
              child: Container(
                height: h * 0.055,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xffFF69A6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.close_rounded,
                          color: Color(0xffFF4F9A),
                        ),

                        SizedBox(width: w * 0.02),

                        customText(
                          text: "رفض الطلب",
                          size: w * 0.04,
                          color: const Color(0xffB1005A),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
