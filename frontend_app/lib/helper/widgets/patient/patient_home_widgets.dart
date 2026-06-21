import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Widget sectionTitle({
  required BuildContext context,
  required double w,
  required String title,
}) {
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
      SizedBox(width: responsiveSize(context, 0.018, min: 7, max: 9)),
      customText(
        text: title,
        size: responsiveSize(context, 0.05, min: 18, max: 22),
        isCenter: false,
      ),
    ],
  );
}

Widget articleCard({
  required BuildContext context,
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
      padding: EdgeInsets.all(responsiveSize(context, 0.028, min: 10, max: 12)),
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
            height: responsiveSize(context, 0.14, min: 52, max: 62),
            width: responsiveSize(context, 0.14, min: 52, max: 62),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: responsiveSize(context, 0.07, min: 26, max: 31),
            ),
          ),

          SizedBox(width: responsiveSize(context, 0.024, min: 9, max: 11)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: topic,
                  size: responsiveSize(context, 0.035, min: 14, max: 16),
                  bold: true,
                  maxLines: 2,
                  isCenter: false,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.005, min: 3, max: 5),
                ),
                customText(
                  text: subTopic,
                  isCenter: false,
                  size: responsiveSize(context, 0.028, min: 12, max: 14),
                  color: Colors.grey,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          SizedBox(width: responsiveSize(context, 0.028, min: 10, max: 12)),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: color,
            size: responsiveSize(context, 0.045, min: 18, max: 22),
          ),
        ],
      ),
    ),
  );
}

Widget navButton({
  required BuildContext context,
  required String title,
  required bool isSelected,
  required VoidCallback onTap,
  required double w,
  required double h,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: responsiveSize(context, 0.45, min: 150, max: 195),
      height: responsiveHeight(context, 0.06, min: 48, max: 58),
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.023, min: 9, max: 11),
      ),
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
            size: responsiveSize(context, 0.05, min: 20, max: 24),
          ),
          SizedBox(width: responsiveSize(context, 0.018, min: 7, max: 9)),
          Expanded(
            child: customText(
              text: title,
              size: responsiveSize(context, 0.045, min: 17, max: 20),
              color: textColor,
              bold: true,
            ),
          ),
          Container(
            width: responsiveSize(context, 0.003, min: 1.3, max: 1.6),
            height: responsiveHeight(context, 0.035, min: 28, max: 32),
            margin: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.028, min: 10, max: 12),
            ),
            color: Colors.pink[100],
          ),
          Container(
            width: responsiveSize(context, 0.095, min: 38, max: 44),
            height: responsiveSize(context, 0.095, min: 38, max: 44),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: responsiveSize(context, 0.055, min: 22, max: 25),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget languageFloatingButton({required BuildContext context}) {
  return AnimatedBuilder(
    animation: localeNotifier,
    builder: (context, _) {
      final label = localeNotifier.isArabic ? 'English' : 'العربية';
      final code = localeNotifier.isArabic ? 'EN' : 'AR';

      return Semantics(
        button: true,
        label: context.tr('تغيير اللغة'),
        child: GestureDetector(
          onTap: () => changeLanguageWithLoading(context),
          child: Container(
            width: responsiveSize(context, 0.45, min: 150, max: 195),
            height: responsiveHeight(context, 0.06, min: 48, max: 58),
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.023, min: 9, max: 11),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.pink[100]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.08),
                  blurRadius: responsiveSize(context, 0.04, min: 14, max: 18),
                  offset: Offset(0, responsiveHeight(context, 0.01, min: 5, max: 8)),
                ),
                BoxShadow(
                  color: Colors.pink[200]!.withOpacity(0.25),
                  blurRadius: responsiveSize(context, 0.04, min: 14, max: 18),
                  offset: Offset(0, responsiveHeight(context, 0.005, min: 3, max: 5)),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  color: Colors.pink[300],
                  size: responsiveSize(context, 0.05, min: 20, max: 24),
                ),
                SizedBox(width: responsiveSize(context, 0.018, min: 6, max: 9)),
                Expanded(
                  child: customText(
                    text: label,
                    size: responsiveSize(context, 0.045, min: 17, max: 20),
                    color: textColor,
                    bold: true,
                    maxLines: 1,
                  ),
                ),
                Container(
                  width: responsiveSize(context, 0.095, min: 36, max: 44),
                  height: responsiveSize(context, 0.095, min: 36, max: 44),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      code,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'ArabicCustomFont',
                        fontSize: responsiveSize(
                          context,
                          0.032,
                          min: 12,
                          max: 14,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
