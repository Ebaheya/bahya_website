import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:flutter/material.dart';

class QuestionModel {
  final String question;
  final List<String> options;
  final bool multiSelect;

  QuestionModel({
    required this.question,
    required this.options,
    this.multiSelect = false,
  });
}

class QuestionCard extends StatelessWidget {
  final int number;
  final QuestionModel question;
  final Set<int> selectedAnswers;
  final Function(int) onSelect;
  final Color pink;
  final Color purple;
  final Color textColor;
  final double w;
  const QuestionCard({
    super.key,
    required this.number,
    required this.question,
    required this.selectedAnswers,
    required this.onSelect,
    required this.pink,

    required this.purple,
    required this.textColor,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: pink.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [purple, pink]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: customText(
                      text: '$number',
                      size: w * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: customText(
                    text: question.question,
                    size: w * 0.037,
                    isCenter: false,
                    maxLines: 3,
                    color: textColor,
                  ),
                ),
                if (question.multiSelect)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: purple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: customText(
                      text: 'اختيار متعدد',
                      size: w * 0.022,
                      color: purple,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            ...List.generate(question.options.length, (index) {
              final selected = selectedAnswers.contains(index);

              return GestureDetector(
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? pink.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? pink : Colors.grey.withOpacity(0.18),
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        question.multiSelect
                            ? (selected
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded)
                            : (selected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded),
                        color: selected ? pink : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: customText(
                          text: question.options[index],
                          size: w * 0.035,
                          isCenter: false,
                          maxLines: 2,
                          color: selected ? textColor : Colors.black87,
                          bold: selected ? true : false,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

Widget questionnaireHeader({
  required double w,
  required double h,
  required int currentPage,
  required int totalPages,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(34),
        bottomRight: Radius.circular(34),
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.22),
              child: Icon(
                Icons.medical_information_rounded,
                color: Colors.white,
                size: w * 0.085,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: 'استبيان التشخيص',
                    size: w * 0.045,
                    color: Colors.white,
                    maxLines: 2,
                  ),
                  SizedBox(height: 4),
                  customText(
                    text: 'يجب الإجابة على كل الأسئلة للمتابعة',
                    size: w * 0.03,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(18),
              ),
              child: customText(
                text: '${currentPage + 1} / $totalPages',
                size: w * 0.035,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: (currentPage + 1) / totalPages,
            minHeight: 7,
            backgroundColor: Colors.white.withOpacity(0.30),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    ),
  );
}

