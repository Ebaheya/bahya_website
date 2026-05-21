import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:flutter/material.dart';

Widget sectionTitle({required double w, required String title}) {
  return Row(
    children: [
      Container(
        width: 4,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.pink[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      customText(text: title, size: w * 0.05, isCenter: false),
    ],
  );
}

Widget articleCard({
  required double w,
  required IconData icon,
  required String topic,
  required String subTopic,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: w * 0.14,
            width: w * 0.14,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: w * 0.07),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: topic,
                  size: w * 0.035,
                  bold: true,
                  maxLines: 2,
                  isCenter: false,
                ),
                const SizedBox(height: 4),
                customText(
                  text: subTopic,
                  isCenter: false,
                  size: w * 0.028,
                  color: Colors.grey,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Icon(Icons.arrow_forward_ios_rounded, color: color, size: w * 0.045),
        ],
      ),
    ),
  );
}

Widget navButton({
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
  required double w,
  required double h,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: w * 0.45,
      height: h * 0.06,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.pink[100]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.pink[200]!.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.pink[300],
            size: w * 0.05,
          ),
          SizedBox(width: 8),
          Expanded(
            child: customText(
              text: title,
              size: w * 0.045,
              color: textColor,
              bold: true,
            ),
          ),
          Container(
            width: 1.5,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.pink[100],
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    ),
  );
}
