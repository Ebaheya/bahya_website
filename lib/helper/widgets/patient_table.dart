import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class PatientTableRowItem extends StatelessWidget {
  final String name;
  final int age;
  final String address;
  final int phq9;
  final int phq4;
  final String diagnosis;
  final VoidCallback onView;

  const PatientTableRowItem({
    super.key,
    required this.name,
    required this.age,
    required this.address,
    required this.phq9,
    required this.phq4,
    required this.diagnosis,
    required this.onView,
  });

  Color getColor(int value) {
    if (value <= 4) return Colors.green.shade300;
    if (value <= 9) return Colors.yellow.shade300;
    if (value <= 14) return Colors.orange.shade300;
    return Colors.red.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: h * 0.012, horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFFFE4F2), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // progress
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: onView,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(h * 0.08, h * 0.03),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    arabicText(
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

          // diagnosis
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerRight,
              child: arabicText(
                text: diagnosis,
                size: h * 0.015,
                color: const Color(0xFF4B2142),
              ),
            ),
          ),

          // PHQ-9
          Expanded(
            flex: 2,
            child: Center(
              child: CircleAvatar(
                radius: h * 0.016,
                backgroundColor: getColor(phq9),
                child: arabicText(
                  text: phq9.toString(),
                  size: h * 0.015,
                  bold: true,
                  color: const Color(0xFF831843),
                ),
              ),
            ),
          ),

          // PHQ-4
          Expanded(
            flex: 2,
            child: Center(
              child: CircleAvatar(
                radius: h * 0.016,
                backgroundColor: getColor(phq4),
                child: arabicText(
                  text: phq4.toString(),
                  size: h * 0.015,
                  bold: true,
                  color: const Color(0xFF831843),
                ),
              ),
            ),
          ),

         //address
          Expanded(
            flex: 4,
            child: arabicText(
              text: address,
              size: h * 0.015,
              color: const Color(0xFF4B2142),
            ),
          ),

         //age
          Expanded(
            flex: 1,
            child: arabicText(text: age.toString(), size: h * 0.015),
          ),

         //name
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: arabicText(
                text: name,
                size: h * 0.015,
                bold: true,
                color: const Color(0xFF7A004C),
              ),
            ),
          ),
        ],
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
          child: arabicText(
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
