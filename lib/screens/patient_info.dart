import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class PatientInfo extends StatefulWidget {
  const PatientInfo({super.key});

  @override
  State<PatientInfo> createState() => _PatientInfoState();
}

class _PatientInfoState extends State<PatientInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        context: context,
        isHomebar: false,
        title: 'معلومات المريض',
      ),
      backgroundColor: const Color(0xFFFDF7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getScreenHeight(context) * 0.05),
            Column(
              children: [
                arabicText(
                  text: "معلومات المريض",
                  size: getScreenHeight(context) * 0.02,
                  color: const Color(0xFF831843),
                  bold: true,
                ),
                const SizedBox(height: 10),
                arabicText(
                  text: "تفاصيل المريض الشخصية والطبية",
                  size: getScreenHeight(context) * 0.015,
                  color: const Color(0xFFEB48A0),
                  bold: true,
                ),
              ],
            ),
            SizedBox(height: getScreenHeight(context) * 0.1),
            // محتوى معلومات المريض هنا
          ],
        ),
      ),
    );
  }
}
