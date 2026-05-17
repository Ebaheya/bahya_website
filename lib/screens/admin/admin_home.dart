import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    return Scaffold(
      appBar: customAppBar(
        preferredSize: Size.fromHeight(getScreenHeight(context) * 0.28),
        context: context,
        title: 'لوحة إدارة الخدمات',
        subTitle: 'مساعدة المحاربات في رحلتهن',
        isHome: false,
        icon: Icons.logout_outlined,
        onIconPressed: () => Navigator.pop(context),
        widgets: [adminStateCards(w: w, h: h)],
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: h * 0.02),
                CustomGlowButton(
                  width: double.infinity,
                  borderRadius: 12,
                  title: "انشاء خدمه جديده ",
                  onPressed: () {
                    Navigator.pushNamed(context, '/addService');
                  },
                  isGradient: true,
                ),
                SizedBox(height: h * 0.02),
                Row(
                  children: [
                    customText(text: "الطلبات الوارده", size: w * 0.035),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          customText(
                            text: "4 طلبات جديده",
                            size: w * 0.03,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),
                requestedServiceCard(
                  w: w,
                  h: h,
                  nameOfPatient: "ساره محمد",
                  medicalNumber: "123456",
                  service: "طلب دعم نفسي",
                  requestDate: "2024-06-15",
                  isSupport: true,
                ),
                SizedBox(height: h * 0.02),
                requestedServiceCard(
                  w: w,
                  h: h,
                  nameOfPatient: "منى أحمد",
                  medicalNumber: "654321",
                  service: "طلب مواصلات",
                  requestDate: "2024-06-14",
                  isTravel: true,
                ),
                SizedBox(height: h * 0.02),
                requestedServiceCard(
                  w: w,
                  h: h,
                  nameOfPatient: "ليلى علي",
                  medicalNumber: "789012",
                  service: "محو اميه المستوى الثالث",
                  requestDate: "2024-06-13",
                ),
                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
                height: h * 0.065,
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
                height: h * 0.065,
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
