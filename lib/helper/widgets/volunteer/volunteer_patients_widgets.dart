
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

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

  bool get _isMobile => getScreenWidth(context) < 700;

  @override
  Widget build(BuildContext context) {
    final titleSize = responsiveHeight(context, 0.036, min: 26, max: 42);
    final subtitleSize = responsiveHeight(context, 0.019, min: 14, max: 20);
    final gap = responsiveHeight(context, 0.024, min: 18, max: 28);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.018, min: 10, max: 18),
          vertical: responsiveHeight(context, 0.014, min: 10, max: 16),
        ),
        child: Column(
          children: [
            customText(
              text: widget.formData["title"],
              size: titleSize,
              bold: true,
              color: const Color(0xFF7A004C),
            ),
            SizedBox(height: responsiveHeight(context, 0.008, min: 6, max: 10)),
            customText(
              text: widget.formData["subtitle"],
              size: subtitleSize,
              color: const Color(0xFFE40070),
              bold: true,
            ),
            SizedBox(height: gap),

            ..._buildQuestions(),

            SizedBox(
              height: responsiveHeight(context, 0.028, min: 22, max: 34),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.02, min: 14, max: 22),
                vertical: responsiveHeight(context, 0.018, min: 14, max: 20),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFD),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE40070).withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: _isMobile ? double.infinity : 330,
                  child: CustomGlowButton(
                    title: "حفظ الإجابات",
                    isGradient: true,
                    glowColor: const Color(0xFFE40070),
                    textSize: responsiveHeight(context, 0.02, min: 15, max: 20),
                    onPressed: () {
                      widget.onSave();

                      customDialog(
                        context: context,
                        title: "تم الحفظ",
                        message: "تم تسجيل الاستبيان بنجاح",
                      );
                    },
                  ),
                ),
              ),
            ),

            SizedBox(
              height: responsiveHeight(context, 0.024, min: 18, max: 26),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildQuestions() {
    return widget.formData["questions"].asMap().entries.map<Widget>((entry) {
      final index = entry.key;
      final q = entry.value;

      return _questionCard(index: index, question: q);
    }).toList();
  }

  Widget _questionCard({required int index, required dynamic question}) {
    final questionSize = responsiveHeight(context, 0.019, min: 15, max: 21);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.022, min: 16, max: 24),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.024, min: 16, max: 26)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.024, min: 18, max: 26),
        ),
        border: Border.all(color: const Color(0xFFF3D7EA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A004C).withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(context, 0.012, min: 8, max: 12),
                    vertical: responsiveHeight(context, 0.006, min: 4, max: 7),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE1F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: customText(
                    text: "${index + 1}".padLeft(2, "0"),
                    size: responsiveHeight(context, 0.015, min: 12, max: 15),
                    bold: true,
                    color: const Color(0xFF7A004C),
                  ),
                ),
                SizedBox(
                  width: responsiveSize(context, 0.012, min: 8, max: 12),
                ),
                Expanded(
                  child: customText(
                    text: "السؤال ${index + 1}: ${question["q"]}",
                    size: questionSize,
                    bold: true,
                    color: const Color(0xFF111827),
                    isCenter: false,
                    align: TextAlign.right,
                    maxLines: 3,
                  ),
                ),
              ],
            ),

            SizedBox(
              height: responsiveHeight(context, 0.018, min: 14, max: 22),
            ),

            ...question["options"].map<Widget>((opt) {
              final selected = answers[index] == opt["text"];

              return _answerOption(
                index: index,
                option: opt,
                selected: selected,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _answerOption({
    required int index,
    required dynamic option,
    required bool selected,
  }) {
    final optionTextSize = responsiveHeight(context, 0.017, min: 13, max: 17);
    final pointTextSize = responsiveHeight(context, 0.014, min: 11, max: 14);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          answers[index] = option["text"];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(
          bottom: responsiveHeight(context, 0.01, min: 8, max: 12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.016, min: 12, max: 16),
          vertical: responsiveHeight(context, 0.012, min: 10, max: 14),
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xFFFFF1F8), Color(0xFFFFFBFD)],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFFF7AB8) : const Color(0xFFEAE7EF),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Radio<String>(
              value: option["text"],
              groupValue: answers[index],
              activeColor: const Color(0xFFE40070),
              onChanged: (value) {
                setState(() {
                  answers[index] = value!;
                });
              },
            ),
            Expanded(
              child: customText(
                text: option["text"],
                size: optionTextSize,
                color: selected
                    ? const Color(0xFF7A004C)
                    : const Color(0xFF111827),
                bold: selected,
                isCenter: false,
                align: TextAlign.right,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.012, min: 8, max: 12),
                vertical: responsiveHeight(context, 0.005, min: 4, max: 6),
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFE1F0)
                    : const Color(0xFFF4F2F7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: customText(
                text: "${option["points"]} نقطة",
                size: pointTextSize,
                bold: true,
                color: selected
                    ? const Color(0xFFE40070)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
