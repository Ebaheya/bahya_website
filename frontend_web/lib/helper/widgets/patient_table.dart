import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/answers_details.dart';
import 'package:flutter/material.dart';

class PatientTableRowItem extends StatefulWidget {
  final String name;
  final int age;
  final String address;
  final int phq9;
  final int phq4;
  final String diagnosis;
  final VoidCallback onView;
  final bool hasAnswers;

  const PatientTableRowItem({
    super.key,
    required this.name,
    required this.age,
    required this.address,
    required this.phq9,
    required this.phq4,
    required this.diagnosis,
    required this.onView,
    required this.hasAnswers,
  });

  @override
  State<PatientTableRowItem> createState() => _PatientTableRowItemState();
}

class _PatientTableRowItemState extends State<PatientTableRowItem> {
  bool isHover = false;

  Color getColor(int value) {
    if (value <= 4) return Colors.green.shade300;
    if (value <= 9) return Colors.yellow.shade300;
    if (value <= 14) return Colors.orange.shade300;
    return Colors.red.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(isHover ? 1.015 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isHover ? Colors.pink.withOpacity(0.4) : Colors.white,
            boxShadow: isHover
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.10),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [],
            border: Border(
              bottom: BorderSide(color: Color(0xFFFFE4F2), width: 1),
            ),
          ),
          child: InkWell(
            onTap: () {
              if (widget.hasAnswers) {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    insetPadding: EdgeInsets.all(20),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: answersDetails(context: context),
                  ),
                );
              } else {
                customDialog(
                  context: context,
                  title: "لا توجد إجابات",
                  message: "لم تقم هذه المريضة بملء أي استبيان بعد.",
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: h * 0.012,
                horizontal: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // progress
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: TextButton(
                        onPressed: widget.onView,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(h * 0.08, h * 0.03),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            customText(
                              text: "عرض التطور",
                              size: h * 0.015,
                              bold: true,
                              color: const Color(0xFFE40070),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.trending_up,
                              color: Color(0xFFE40070),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: customText(
                        text: widget.diagnosis,
                        size: h * 0.015,
                        color: const Color(0xFF4B2142),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Center(
                      child: CircleAvatar(
                        radius: h * 0.016,
                        backgroundColor: getColor(widget.phq9),
                        child: customText(
                          text: widget.phq9.toString(),
                          size: h * 0.015,
                          bold: true,
                          color: const Color(0xFF831843),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 2,
                    child: Center(
                      child: CircleAvatar(
                        radius: h * 0.016,
                        backgroundColor: getColor(widget.phq4),
                        child: customText(
                          text: widget.phq4.toString(),
                          size: h * 0.015,
                          bold: true,
                          color: const Color(0xFF831843),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 4,
                    child: customText(
                      text: widget.address,
                      size: h * 0.015,
                      color: const Color(0xFF4B2142),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: customText(
                      text: widget.age.toString(),
                      size: h * 0.015,
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: customText(
                        text: widget.name,
                        size: h * 0.015,
                        bold: true,
                        color: const Color(0xFF7A004C),
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
}

class PatientTableHeader extends StatelessWidget {
  const PatientTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    Widget headerCell(String text, {required int flex}) {
      return Expanded(
        flex: flex,
        child: Center(
          child: customText(
            text: text,
            size: h * 0.015,
            isCenter: true,
            bold: true,
            color: const Color(0xFF7A004C),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: h * 0.013, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFE4F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          headerCell("التطور", flex: 2),
          headerCell("التشخيص النفسي", flex: 4),
          headerCell("PHQ-9", flex: 2),
          headerCell("PHQ-4", flex: 2),
          headerCell("العنوان", flex: 4),
          headerCell("السن", flex: 1),
          headerCell("الاسم", flex: 3),
        ],
      ),
    );
  }
}
