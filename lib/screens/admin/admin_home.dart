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
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 0),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              height: h * 0.1,
              width: w * 0.2,
              decoration: BoxDecoration(
                color: isTravel
                    ? Colors.blue[100]!
                    : (isSupport ? Colors.purple[100]! : Colors.green[100]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isTravel
                    ? Icons.directions_bus_rounded
                    : (isSupport
                          ? Icons.groups_rounded
                          : Icons.menu_book_rounded),
                color: isTravel
                    ? Colors.blue[400]!
                    : (isSupport ? Colors.purple[400]! : Colors.green[400]!),
                size: w * 0.1,
              ),
            ),
            SizedBox(width: w * 0.02),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(text: nameOfPatient, size: w * 0.035),
                customText(
                  text: 'الرقم الطبى : $medicalNumber',
                  size: w * 0.035,
                ),
                SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple[200]!.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      customText(
                        text: 'الخدمه: $service',
                        size: w * 0.03,
                        color: Colors.black,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 4),
                      customText(
                        text: "تاريخ الطلب : $requestDate",
                        size: w * 0.03,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: h * 0.02),
        Row(
          children: [
            CustomGlowButton(
              width: w * 0.3,
              height: h * 0.04,
              borderRadius: 12,
              title: "قبول الطلب",
              onPressed: () {},
              isGradient: true,
              textSize: w * 0.04,
            ),
            const Spacer(),
            CustomGlowButton(
              width: w * 0.3,
              height: h * 0.04,
              borderRadius: 12,
              title: "رفض الطلب",
              onPressed: () {},
              isGradient: false,
              textSize: w * 0.04,
            ),
          ],
        ),
      ],
    ),
  );
}
