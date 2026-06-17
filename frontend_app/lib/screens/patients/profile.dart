import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
final WebService webService = WebService();
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                  ],
                ),
                profileItem(
                  primaryColor: Colors.green[100]!,
                  secondaryColor: Colors.green[400]!,
                  h: h,
                  title: "الاسم بالكامل",
                  icon: Icons.person,
                  value: 'فاطمة أحمد محمود',
                  w: w,
                ),
                profileItem(
                  primaryColor: Colors.blue[100]!,
                  secondaryColor: Colors.blue[400]!,
                  h: h,
                  title: 'السن',
                  icon: Icons.calendar_today,
                  value: '28 سنة',
                  w: w,
                ),
                profileItem(
                  primaryColor: Colors.orange[100]!,
                  secondaryColor: Colors.orange[400]!,
                  title: "الرقم الطبى",
                  icon: Icons.medical_services,
                  value: '123456789',
                  w: w,
                  h: h,
                ),
                profileItem(
                  primaryColor: Colors.purple[100]!,
                  secondaryColor: Colors.purple[400]!,
                  title: "رقم الهاتف",
                  icon: Icons.phone,
                  value: '123456789',
                  w: w,
                  h: h,
                  isPhoneNumber: true,
                ),
                SizedBox(height: h * 0.03),
                CustomGlowButton(
                  title: "تسجيل الخروج",
                  onPressed: () async {
                    await webService.logout();
                  },
                  textColor: Colors.white,
                  backgroundColor:Colors.purple[400]!,

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget profileItem({
  required String title,
  required String value,
  required double w,
  required double h,
  required IconData icon,
  required Color primaryColor,
  required Color secondaryColor,
  bool? isPhoneNumber = false,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
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
          padding: const EdgeInsets.all(6),
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
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(text: title, size: w * 0.035, color: Colors.grey),
            SizedBox(height: 4),
            customText(text: value, size: w * 0.04),
          ],
        ),
        Spacer(),
        isPhoneNumber == true
            ? Container(
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
                child: SizedBox(
                  width: w * 0.09,
                  height: h * 0.04,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.edit_outlined,
                      size: w * 0.05,
                      color: secondaryColor,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    ),
  );
}
