import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

/// ================= Patients List =================
class PatientsListWidget extends StatelessWidget {
  final String selectedPatient;
  final Set<String> completedPatients;
  final ValueChanged<String> onSelect;

  const PatientsListWidget({
    super.key,
    required this.selectedPatient,
    required this.completedPatients,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    final patients = [
      "أسماء محمد",
      "فاطمة علي",
      "منى حسين",
      "سارة أحمد",
      "هدى إبراهيم",
    ];

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            text: "قائمة المريضات",
            size: h * 0.02,
            bold: true,
            color: const Color(0xFF831843),
          ),
          const SizedBox(height: 16),
          ...patients.map((p) {
            final isDone = completedPatients.contains(p);

            return InkWell(
              onTap: () => onSelect(p),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green.withOpacity(0.15)
                      : p == selectedPatient
                      ? const Color(0xFFFCEFFE)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone ? Colors.green : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: customText(
                        text: p,
                        size: h * 0.016,
                        bold: isDone || p == selectedPatient,
                        color: isDone ? Colors.green.shade800 : Colors.black87,
                      ),
                    ),
                    if (isDone)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// ================= Volunteer Survey =================
class VolunteerSurveyWidget extends StatefulWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onSave;

  const VolunteerSurveyWidget({
    super.key,
    required this.formData,
    required this.onSave,
  });

  @override
  State<VolunteerSurveyWidget> createState() => _VolunteerSurveyWidgetState();
}

class _VolunteerSurveyWidgetState extends State<VolunteerSurveyWidget> {
  String? selectedVolunteer;
  Map<int, String> answers = {};

  final volunteers = ["سارة علي", "أحمد محمد", "منى حسن", "يوسف إبراهيم"];

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: customText(
              text: "إمضاء المتطوع",
              size: h * 0.018,
              bold: true,
              color: const Color(0xFF7A004C),
            ),
          ),
          const SizedBox(height: 8),
          _volunteerDropdown(h),

          const SizedBox(height: 30),

          customText(
            text: widget.formData["title"],
            size: h * 0.032,
            bold: true,
            color: const Color(0xFF7A004C),
          ),

          const SizedBox(height: 8),

          customText(
            text: widget.formData["subtitle"],
            size: h * 0.02,
            color: const Color(0xFFE40070),
          ),

          const SizedBox(height: 30),

          ..._buildQuestions(),

          const SizedBox(height: 30),

          CustomGlowButton(
            title: "حفظ الإجابات",
            onPressed: () {
              if (selectedVolunteer == null) {
                customDialog(
                  context: context,
                  title: "تنبيه",
                  message: "من فضلك اختر اسم المتطوع أولاً",
                );
                return;
              }

              widget.onSave();

              customDialog(
                context: context,
                title: "تم الحفظ",
                message: "تم تسجيل الاستبيان بنجاح",
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _volunteerDropdown(double h) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          alignment: Alignment.centerRight,
          hint: customText(
            text: "اختر اسم المتطوع",
            size: h * 0.016,
            color: Colors.grey,
          ),
          value: selectedVolunteer,
          items: volunteers
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  alignment: Alignment.centerRight,
                  child: customText(text: v, size: h * 0.016),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => selectedVolunteer = val),
        ),
      ),
    );
  }

  List<Widget> _buildQuestions() {
    final h = getScreenHeight(context);

    return widget.formData["questions"].asMap().entries.map<Widget>((entry) {
      final index = entry.key;
      final q = entry.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6FB),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            customText(
              text: "السؤال ${index + 1}: ${q["q"]}",
              size: h * 0.02,
              bold: true,
              color: const Color(0xFF7A004C),
            ),
            const SizedBox(height: 20),
            ...q["options"].map<Widget>((opt) {
              return Row(
                children: [
                  customText(
                    text: "(${opt["points"]} نقطة)",
                    size: h * 0.015,
                    bold: true,
                    color: const Color(0xFF7A00C4),
                  ),
                  const Spacer(),
                  Radio(
                    value: opt["text"],
                    groupValue: answers[index],
                    activeColor: const Color(0xFF7A004C),
                    onChanged: (v) =>
                        setState(() => answers[index] = v.toString()),
                  ),
                  customText(
                    text: opt["text"],
                    size: h * 0.018,
                    color: const Color(0xFF7A004C),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      );
    }).toList();
  }
}
