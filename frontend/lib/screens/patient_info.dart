import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/patient_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/widgets/patient_table.dart';

class PatientInfo extends StatefulWidget {
  const PatientInfo({super.key});

  @override
  State<PatientInfo> createState() => _PatientInfoState();
}

class _PatientInfoState extends State<PatientInfo> {
  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: 'معلومات المرضى',
        isHomeBar: false,
      ),
      backgroundColor: const Color(0xFFFDF7FB),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: h * 0.05, bottom: h * 0.03),
          child: Center(
            child: Container(
              width: w * 0.95,
              padding: EdgeInsets.all(h * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    spreadRadius: 1,
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        customText(
                          text: "قائمة المرضى المسجلين",
                          size: h * 0.02,
                          color: const Color(0xFF831843),
                          bold: true,
                          isCenter: false,
                        ),
                        customText(
                          text:
                              "عرض شامل لبيانات المرضى ونتائج التقييمات النفسية",
                          size: h * 0.015,
                          color: const Color(0xFF831843),
                          bold: true,
                          isCenter: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: w * 0.93),
                      child: IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const PatientTableHeader(),
                            ..._buildPatientRows(context: context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPatientRows({required BuildContext context}) {
    return patients
        .map(
          (p) => PatientTableRowItem(
            name: p["name"] as String,
            age: p["age"] as int,
            address: p["address"] as String,
            phq9: p["phq9"] as int,
            phq4: p["phq4"] as int,
            diagnosis: p["diag"] as String,
            onView: () {
              debugPrint("عرض تطور المريض: ${p["name"]}");
              showPatientProgressDialog(
                context: context,
                patient: demoPatients[0],
              );
            },
            hasAnswers: p["hasAnswers"] as bool,
          ),
        )
        .toList();
  }
}
