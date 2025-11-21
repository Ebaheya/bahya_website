import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/diagnosis_patients_dialog.dart';
import 'package:bahya_website/helper/widgets/patient_progress_dialog.dart';
import 'package:flutter/material.dart';

class PatientRow extends StatefulWidget {
  final PatientDiagnosisItem item;
  const PatientRow({super.key, required this.item});

  @override
  State<PatientRow> createState() => _PatientRowState();
}

class _PatientRowState extends State<PatientRow> {
  bool _hover = false;

  void _setHover(bool v) => setState(() => _hover = v);

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    final Color bgColor = _hover
        ? const Color(0xFFFFF5FB)
        : Colors.white; 

    final List<BoxShadow> shadow = _hover
        ? const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ];

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: h * 0.018,
            vertical: h * 0.012,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: shadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: h * 0.028,
                    backgroundColor: const Color(0xFFFFE7F1),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        arabicText(
                          text: widget.item.name,
                          size: h * 0.015,
                          bold: true,
                          color: const Color(0xFF7A004C),
                          isCenter: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: const Color(0xFFFFF1F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();

                      Future.microtask(() {
                        showPatientProgressDialog(
                          context: context,
                          patient: widget.item, 
                        );
                      });
                    },
                    icon: const Icon(
                      Icons.trending_up,
                      size: 18,
                      color: Color(0xFFE91E63),
                    ),
                    label: arabicText(
                      text: "عرض التفاصيل",
                      size: h * 0.015,
                      color: const Color(0xFFE91E63),
                      bold: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  arabicText(
                    text: "العمر: ${widget.item.age} سنة",
                    size: h * 0.012,
                    color: Colors.black54,
                    isCenter: false,
                  ),
                  const SizedBox(width: 16),
                  arabicText(
                    text: "PHQ-9: ${widget.item.phq9}",
                    size: h * 0.012,
                    color: Colors.black54,
                    isCenter: false,
                  ),
                  const SizedBox(width: 12),
                  arabicText(
                    text: "PHQ-4: ${widget.item.phq4}",
                    size: h * 0.012,
                    color: Colors.black54,
                    isCenter: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
