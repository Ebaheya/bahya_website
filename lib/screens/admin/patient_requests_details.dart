import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class PatientRequestsDetails extends StatelessWidget {
  const PatientRequestsDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    return Scaffold(
            extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: customAppBar(
        context: context,
        title: 'تفاصيل طلب المريضة',
        subTitle: 'مساعدة المحاربات في رحلتهن',
        isHome: false,
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                patientDetailsCard(
                  w: w,
                  h: h,
                  patientName: "سارة أحمد",
                  phoneNumber: "0123456789",
                  registerDate: "15 مارس 2024",
                  age: "35 سنة",
                  isActive: true,
                ),
                SizedBox(height: h * 0.02),
                serviceInfo(
                  forAdmin: true,
                  isTravel: true,
                  w: w,
                  h: h,
                  title: 'دروس محو الأمية - المستوى الأول',
                  date: 'السبت والاثنين والأربعاء',
                  time: '5:00 مساءً - 6:30 مساءً',
                  location: 'بهيه - الشيخ زايد',
                  meetingPlace: 'محطة مترو الشيخ زايد',
                ),
                serviceInfo(
                  forAdmin: true,
                  isUnderReview: true,
                  isSupport: true,
                  w: w,
                  h: h,
                  title: 'دروس محو الأمية - المستوى الأول',
                  date: 'السبت والاثنين والأربعاء',
                  time: '5:00 مساءً - 6:30 مساءً',
                  location: 'بهيه - الشيخ زايد',
                ),
                serviceInfo(
                  forAdmin: true,
                  isAccepted: true,

                  w: w,
                  h: h,
                  title: 'دروس محو الأمية - المستوى الأول',
                  date: 'السبت والاثنين والأربعاء',
                  time: '5:00 مساءً - 6:30 مساءً',
                  location: 'بهيه - الشيخ زايد',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget patientDetailsCard({
    required double w,
    required double h,
    required String patientName,
    required String phoneNumber,
    required String registerDate,
    required String age,
    required bool isActive,
  }) {
    final Color statusColor = isActive ? Colors.green : Colors.red;
    final String statusText = isActive ? "نشطة" : "غير نشطة";

    Widget infoItem({
      required IconData icon,
      required String title,
      required String value,
    }) {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: h * 0.05,
              height: h * 0.05,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: w * 0.05),
            ),

            SizedBox(width: w * 0.025),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: title,
                  size: w * 0.026,
                  color: Colors.grey[700],
                ),

                SizedBox(height: h * 0.003),

                customText(
                  text: value,
                  size: w * 0.03,
                  color: const Color(0xff14213D),
                  bold: true,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.pink.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -25,
            top: -20,
            child: Icon(
              Icons.favorite_border_rounded,
              size: w * 0.28,
              color: Colors.pink.withOpacity(0.05),
            ),
          ),

          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: h * 0.11,
                    height: h * 0.11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: w * 0.12,
                    ),
                  ),

                  SizedBox(width: w * 0.05),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          text: patientName,
                          size: w * 0.05,
                          bold: true,
                          color: const Color(0xff14213D),
                          maxLines: 1,
                        ),

                        SizedBox(height: h * 0.005),

                        customText(
                          text: phoneNumber,
                          size: w * 0.032,
                          color: Colors.grey[700],
                          maxLines: 1,
                        ),

                        SizedBox(height: h * 0.012),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: statusColor,
                                size: w * 0.035,
                              ),

                              SizedBox(width: w * 0.015),

                              customText(
                                text: statusText,
                                size: w * 0.028,
                                color: statusColor,
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: h * 0.025),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.03,
                  vertical: h * 0.018,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8FB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.pink.withOpacity(0.08)),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      infoItem(
                        icon: Icons.calendar_month_rounded,
                        title: "تاريخ التسجيل",
                        value: registerDate,
                      ),

                      VerticalDivider(
                        color: Colors.pink.withOpacity(0.3),
                        thickness: 1,
                        width: w * 0.06,
                      ),

                      infoItem(
                        icon: Icons.person_outline_rounded,
                        title: "العمر",
                        value: age,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
