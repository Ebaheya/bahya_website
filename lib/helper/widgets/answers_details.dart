import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

Widget answersDetails({required BuildContext context}) {
  final h = getScreenHeight(context);
  final w = getScreenWidth(context);

  return SingleChildScrollView(
    child: Container(
      width: w * 0.7,
      padding: EdgeInsets.all(h * 0.02),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              heartSign(iconSize: 30, containerSize: 40),
              SizedBox(width: w * 0.02),
              arabicText(
                text: "تفاصيل الإجابات",
                size: h * 0.025,
                bold: true,
                color: const Color(0xFF7A004C),
              ),
            ],
          ),

          SizedBox(height: h * 0.03),


          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Container(
              padding: EdgeInsets.all(h * 0.02),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFFE4F4),
              ),
              child: Column(
                children: [
                  SizedBox(height: h * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          arabicText(
                            text: "اسم المريضة",
                            size: h * 0.017,
                            color: const Color(0xFF4B2142),
                          ),
                          SizedBox(height: h * 0.01),
                          arabicText(
                            text: "حسناء أحمد",
                            size: h * 0.016,
                            color: Colors.black,
                          ),
                          SizedBox(height: h * 0.02),
                          arabicText(
                            text: "تاريخ الإجابة",
                            size: h * 0.017,
                            color: const Color(0xFF4B2142),
                          ),
                          SizedBox(height: h * 0.01),
                          arabicText(
                            text: "11-06-2024",
                            size: h * 0.015,
                            color: Colors.black,
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          arabicText(
                            text: "اسم الفورم",
                            size: h * 0.017,
                            color: const Color(0xFF4B2142),
                          ),
                          SizedBox(height: h * 0.01),
                          arabicText(
                            text: "استبيان PHQ-9",
                            size: h * 0.015,
                            color: Colors.black,
                          ),
                          SizedBox(height: h * 0.02),
                          arabicText(
                            text: "السكور الكلي",
                            size: h * 0.017,
                            color: const Color(0xFF4B2142),
                          ),
                          SizedBox(height: h * 0.01),
                          arabicText(
                            text: "8",
                            size: h * 0.015,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: h * 0.03),

          arabicText(
            text: "الإجابات التفصيلية",
            size: h * 0.025,
            bold: true,
            color: const Color(0xFF7A004C),
          ),

          SizedBox(height: h * 0.02),
          SizedBox(
            height: h * 0.45,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  answerOfQuestion(h),
                  answerOfQuestion(h),
                  answerOfQuestion(h),
                  answerOfQuestion(h),
                ],
              ),
            ),
          ),

          CustomGlowButton(
            title: "حذف الاجابات",
            onPressed: () {},
            width: w * 0.4,
          ),
          SizedBox(height: h * 0.02),
          CustomGlowButton(
            title: "الاجابه مره اخرى",
            onPressed: () {},
            width: w * 0.4,
          ),
        ],
      ),
    ),
  );
}

Widget answerOfQuestion(double h) {
  return Padding(
    padding: const EdgeInsets.all(6),
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          arabicText(
            text:
                "السؤال 1: هل شعرت بقلة الاهتمام أو المتعة في القيام بالأشياء؟",
            size: h * 0.018,
            bold: true,
            color: const Color(0xFF7A004C),
            isCenter: false,
          ),

          SizedBox(height: 8),

          arabicText(
            text: "الإجابة: أكثر من نصف الأيام",
            size: h * 0.018,
            color: Colors.black,
            isCenter: false,
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7C2F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: arabicText(
                  text: "السكور: 2",
                  size: h * 0.017,
                  color: const Color(0xFF7A004C),
                  bold: true,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

