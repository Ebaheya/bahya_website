import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class SavedFormsWidget extends StatelessWidget {
  final String selectedForm;
  final Function(String) onSelect;

  const SavedFormsWidget({
    super.key,
    required this.selectedForm,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);
    final forms = ["استبيان PHQ-9", "استبيان PHQ-4", "تقييم القلق العام"];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              arabicText(
                text: "النماذج المحفوظة",
                size: h * 0.025,
                bold: true,
                color: Color(0xFF7A004C),
                isCenter: false,
              ),
              SizedBox(width: w * 0.01),
              Icon(Icons.folder_open, color: Color(0xFF7A004C), size: 28),
            ],
          ),

          const SizedBox(height: 25),

          // Items
          ...forms.map((f) {
            final bool active = selectedForm == f;

            return GestureDetector(
              onTap: () => onSelect(f),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: active
                        ? const LinearGradient(
                            colors: [Color(0xFFFF9BDD), Color(0xFFC38CFF)],
                          )
                        : null,
                    color: active ? null : const Color(0xFFF8ECF7),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        arabicText(
                          text: f,
                          size: h * 0.02,
                          bold: true,
                          color: active ? Colors.white : Color(0xFF7A004C),
                        ),
                        Icon(
                          Icons.description,
                          color: active ? Colors.white : Color(0xFF7A004C),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DynamicFormFillerWidget extends StatefulWidget {
  final Map<String, dynamic> formData;

  const DynamicFormFillerWidget({super.key, required this.formData});

  @override
  State<DynamicFormFillerWidget> createState() =>
      _DynamicFormFillerWidgetState();
}

class _DynamicFormFillerWidgetState extends State<DynamicFormFillerWidget> {
  Map<int, String> answers = {};

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TITLE
          arabicText(
            text: widget.formData["title"],
            size: h * 0.035,
            bold: true,
            color: const Color(0xFF7A004C),
          ),

          const SizedBox(height: 10),

          // SUBTITLE
          arabicText(
            text: widget.formData["subtitle"],
            size: h * 0.02,
            color: const Color(0xFFE40070),
          ),

          const SizedBox(height: 25),

          ..._buildFields(),

          const SizedBox(height: 25),

          ..._buildQuestionList(),

          const SizedBox(height: 30),

          CustomGlowButton(
            title: "حفظ الإجابات",
            onPressed: () {
              customDialog(
                context: context,
                title: "تم حفظ الإجابات",
                message: "المريض مشخص ب ...",
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------- BUILD TEXT FIELDS ----------
  List<Widget> _buildFields() {
    if (widget.formData["fields"] == null) return [];

    return widget.formData["fields"].map<Widget>((field) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomFormTextField(
            labelText: field["label"],
            hintText: field["hint"],
            autovalidateMode: AutovalidateMode.disabled,
            keyboardType: CustomTextFieldType.text,
          ),
        ),
      );
    }).toList();
  }

  // ---------- BUILD QUESTION LIST ----------
  List<Widget> _buildQuestionList() {
    final h = getScreenHeight(context);

    return widget.formData["questions"].asMap().entries.map<Widget>((entry) {
      final index = entry.key;
      final question = entry.value;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6FB),
          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            arabicText(
              text: "السؤال ${index + 1}: ${question["q"]}",
              size: h * 0.02,
              bold: true,
              color: const Color(0xFF7A004C),
            ),

            const SizedBox(height: 20),

            ...question["options"].map<Widget>((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    arabicText(
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
                      onChanged: (v) {
                        setState(() => answers[index] = v.toString());
                      },
                    ),

                    const SizedBox(width: 6),

                    arabicText(
                      text: opt["text"],
                      size: h * 0.018,
                      color: const Color(0xFF7A004C),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    }).toList();
  }
}
