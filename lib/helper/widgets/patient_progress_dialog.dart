import 'package:bahya_website/helper/widgets/progress_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/diagnosis_patients_dialog.dart'
    show PatientDiagnosisItem;

Future<void> showPatientProgressDialog({
  required BuildContext context,
  required PatientDiagnosisItem patient,
}) {
  final h = getScreenHeight(context);
  final w = getScreenWidth(context);

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'patient-progress',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: w > 800 ? 720 : w * 0.92,
              margin: EdgeInsets.symmetric(vertical: h * 0.03),
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
              child: _PatientProgressContent(patient: patient),
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

class _PatientProgressContent extends StatefulWidget {
  final PatientDiagnosisItem patient;
  const _PatientProgressContent({required this.patient});

  @override
  State<_PatientProgressContent> createState() =>
      _PatientProgressContentState();
}

class _PatientProgressContentState extends State<_PatientProgressContent> {
  bool _weekly = true;

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // الهيدر
        Container(
          padding: EdgeInsets.symmetric(vertical: h * 0.015),
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
              const SizedBox(width: 10),
              customText(
                text: widget.patient.name,
                size: h * 0.02,
                color: const Color(0xFF7A004C),
                bold: true,
                isCenter: false,
              ),
              const Spacer(),
              Row(
                children: [
                  _PeriodButton(
                    title: "أسبوعي",
                    selected: _weekly,
                    onTap: () => setState(() => _weekly = true),
                  ),
                  SizedBox(width: w * 0.01),
                  _PeriodButton(
                    title: "شهري",
                    selected: !_weekly,
                    onTap: () => setState(() => _weekly = false),
                  ),
                  SizedBox(width: w * 0.01),
                  IconButton(
                    splashRadius: 22,
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF7A004C),
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: h * 0.02),

        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(h * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.show_chart,
                            color: Color(0xFF7A004C),
                          ),
                          const SizedBox(width: 8),
                          customText(
                            text: "رسم بياني لتطور الحالة",
                            size: h * 0.02,
                            bold: true,
                            color: const Color(0xFF7A004C),
                            isCenter: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      customText(
                        text:
                            "يوضح هذا الرسم التحسن في مستويات الاكتئاب والقلق خلال فترة العلاج",
                        size: h * 0.014,
                        color: Colors.black54,
                        isCenter: false,
                      ),
                      SizedBox(height: h * 0.02),

                      SizedBox(
                        height: h * 0.28,
                        child: ProgressLineChart(weekly: _weekly),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.02),

                Wrap(
                  spacing: w * 0.02,
                  runSpacing: h * 0.015,
                  children: [
                    _StatSmallCard(
                      title: "معدل التحسن الإجمالي",
                      value: "60%",
                      color: const Color(0xFFFFCDD2),
                    ),
                    _StatSmallCard(
                      title: "نسبة انخفاض الاكتئاب",
                      value: "62%",
                      color: const Color(0xFFE1BEE7),
                    ),
                    _StatSmallCard(
                      title: "نسبة انخفاض القلق",
                      value: "64%",
                      color: const Color(0xFFC8E6C9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFFE91E63) : Colors.white70,
            width: 1.1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 14,
              color: Color(0xFFE91E63),
            ),
            const SizedBox(width: 4),
            customText(
              text: title,
              size: h * 0.014,
              color: const Color(0xFFE91E63),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatSmallCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatSmallCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return SizedBox(
      width: (w > 900 ? 220 : w * 0.45),
      child: Container(
        padding: EdgeInsets.all(h * 0.016),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: title,
              size: h * 0.017,
              bold: true,
              color: const Color(0xFF7A004C),
              isCenter: false,
            ),
            const SizedBox(height: 8),
            customText(
              text: value,
              size: h * 0.02,
              bold: true,
              color: const Color(0xFF7A004C),
              isCenter: false,
            ),
          ],
        ),
      ),
    );
  }
}
