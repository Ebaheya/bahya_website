import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    return Scaffold(
      appBar: customAppBar(
        preferredSize: Size.fromHeight(getScreenHeight(context) * 0.3),
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
                CustomGlowButton(
                  width: double.infinity,
                  borderRadius: 12,
                  title: "تاريخ الطلبات",
                  onPressed: () {
                    Navigator.pushNamed(context, '/patientsSearch');
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
