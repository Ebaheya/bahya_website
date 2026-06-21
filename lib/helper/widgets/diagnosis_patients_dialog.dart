import 'package:bahya_website/helper/widgets/diagons_patient_row.dart';
import 'package:flutter/material.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';

class PatientDiagnosisItem {
  final String name;
  final int age;
  final int phq9;
  final int phq4;

  PatientDiagnosisItem({
    required this.name,
    required this.age,
    required this.phq9,
    required this.phq4,
  });
}

Future<void> showDiagnosisPatientsDialog({
  required BuildContext context,
  required String diagnosisTitle,
  required List<PatientDiagnosisItem> patients,
  required int averageAge,
}) {
  final h = getScreenHeight(context);
  final w = getScreenWidth(context);

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'patients',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: w > 800 ? 720 : w * 0.92,
              padding: EdgeInsets.all(h * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 30,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: h * 0.02,
                      vertical: h * 0.015,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF9D5FF), Color(0xFFFFE0F0)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: h * 0.025,
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: customText(
                            text: diagnosisTitle,
                            size: h * 0.015,
                            bold: true,
                            color: const Color(0xFF7A004C),
                          ),
                        ),
                        IconButton(
                          splashRadius: 20,
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF7A004C),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: h * 0.02),

                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: patients.length,
                      separatorBuilder: (_, __) => SizedBox(height: h * 0.015),
                      itemBuilder: (_, i) {
                        final p = patients[i];
                        return PatientRow(item: p);
                      },
                    ),
                  ),

                  SizedBox(height: h * 0.018),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: h * 0.02,
                      vertical: h * 0.014,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE1EC), Color(0xFFEBD9FF)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText(
                                text: "إجمالي المريضات",
                                size: h * 0.016,
                                bold: true,
                                color: const Color(0xFF7A004C),
                              ),
                              const SizedBox(height: 2),
                              customText(
                                text: patients.length.toString(),
                                size: h * 0.018,
                                color: const Color(0xFFB0005B),
                                bold: true,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              customText(
                                text: "متوسط العمر",
                                size: h * 0.016,
                                bold: true,
                                color: const Color(0xFF7A004C),
                              ),
                              const SizedBox(height: 2),
                              customText(
                                text: "$averageAge سنة",
                                size: h * 0.018,
                                color: const Color(0xFFB0005B),
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
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}
