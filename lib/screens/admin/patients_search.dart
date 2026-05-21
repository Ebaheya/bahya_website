import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/custom_searchbar.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class PatientsSearch extends StatelessWidget {
  const PatientsSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);
    return Scaffold(
      appBar: customAppBar(
        context: context,
        preferredSize: Size.fromHeight(h * 0.2),
        title: 'بحث عن مريض',
        subTitle: 'ابحث عن المحاربات في رحلتهن',
        isHome: false,
        icon: Icons.arrow_back_ios_new_outlined,
        onIconPressed: () => Navigator.pop(context),
        widgets: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchBarWithFilter(
              hintText: 'ابحثي عن اسم المريضة...',
              onChanged: (value) {
                // Handle search query change
              },
              onFilterTap: () {
                // Handle filter tap
              },
              onSearchTap: () {
                // Handle search tap
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              SizedBox(height: h * 0.02),
              patientCard(
                w: w,
                h: h,
                patientName: "سارة أحمد",
                phoneNumber: "0123456789",
                isActive: true,
                onTap: () {
                  // Handle patient card tap
                  Navigator.pushNamed(context, '/patientRequestsDetails');
                },
              ),
              SizedBox(height: h * 0.01),
              patientCard(
                w: w,
                h: h,
                patientName: "ليلى محمد",
                phoneNumber: "0987654321",
                isActive: false,
                onTap: () {
                  // Handle patient card tap
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget patientCard({
    required double w,
    required double h,
    required String patientName,
    required String phoneNumber,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color statusColor = isActive ? Colors.green : Colors.red;
    final String statusText = isActive ? "نشطة" : "غير نشطة";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: w * 0.055,
              backgroundColor: Colors.pink[50],
              child: Icon(
                Icons.person_rounded,
                color: Colors.pink[300],
                size: w * 0.055,
              ),
            ),

            SizedBox(width: w * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                customText(
                  text: patientName,
                  size: w * 0.032,
                  bold: true,
                  color: const Color(0xff14213D),
                ),
                const SizedBox(height: 4),
                customText(
                  text: phoneNumber,
                  size: w * 0.028,
                  color: Colors.grey,
                ),
              ],
            ),

            Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: customText(
                text: statusText,
                size: w * 0.027,
                color: statusColor,
                bold: true,
              ),
            ),
            SizedBox(width: w * 0.06),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.pink[300],
              size: w * 0.035,
            ),
          ],
        ),
      ),
    );
  }
}
