import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay?> customTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
}) async {
  final isMobile = getScreenWidth(context) < 650;

  return await showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
    builder: (context, child) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(
              context,
            ).textTheme.apply(fontFamily: "ArabicCustomFont"),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE7549B),
              onPrimary: Colors.white,
              surface: Color(0xFFFEFBFD),
              onSurface: Color(0xFF272044),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.02, min: 18, max: 24),
                ),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFFFEFBFD),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.024, min: 20, max: 28),
                ),
                side: BorderSide(
                  color: const Color(0xFFE7549B).withValues(alpha: 0.12),
                ),
              ),
              padding: EdgeInsets.all(
                responsiveSize(context, 0.018, min: 14, max: 24),
              ),
              helpTextStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(context, 0.012, min: 14, max: 18),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8A0057),
              ),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.016, min: 16, max: 22),
                ),
                side: BorderSide(
                  color: const Color(0xFFE7549B).withValues(alpha: 0.14),
                ),
              ),
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFE7549B);
                }

                return Colors.white.withValues(alpha: 0.86);
              }),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }

                return const Color(0xFF8A0057);
              }),
              hourMinuteTextStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(
                  context,
                  isMobile ? 0.09 : 0.04,
                  min: 36,
                  max: 52,
                ),
                fontWeight: FontWeight.bold,
              ),
              dialBackgroundColor: const Color(0xFFF8EEF6),
              dialHandColor: const Color(0xFFE7549B),
              dialTextColor: const Color(0xFF272044),
              dialTextStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(context, 0.012, min: 13, max: 16),
                fontWeight: FontWeight.w600,
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.014, min: 14, max: 18),
                ),
                side: BorderSide(
                  color: const Color(0xFFE7549B).withValues(alpha: 0.18),
                ),
              ),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFFFE4F0);
                }

                return Colors.white;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFE7549B);
                }

                return const Color(0xFF272044);
              }),
              dayPeriodBorderSide: BorderSide(
                color: const Color(0xFFE7549B).withValues(alpha: 0.22),
              ),
              dayPeriodTextStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(context, 0.011, min: 12, max: 15),
                fontWeight: FontWeight.bold,
              ),
              entryModeIconColor: const Color(0xFFE7549B),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.86),
                contentPadding: EdgeInsets.symmetric(
                  vertical: responsiveHeight(context, 0.014, min: 12, max: 15),
                  horizontal: responsiveSize(context, 0.012, min: 12, max: 16),
                ),
                labelStyle: TextStyle(
                  fontFamily: "ArabicCustomFont",
                  fontSize: responsiveSize(context, 0.011, min: 12, max: 15),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8A0057),
                ),
                hintStyle: TextStyle(
                  fontFamily: "ArabicCustomFont",
                  fontSize: responsiveSize(context, 0.011, min: 12, max: 15),
                  color: Colors.grey.shade500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.012, min: 12, max: 16),
                  ),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.012, min: 12, max: 16),
                  ),
                  borderSide: BorderSide(
                    color: const Color(0xFFE7549B).withValues(alpha: 0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.012, min: 12, max: 16),
                  ),
                  borderSide: BorderSide(
                    color: const Color(0xFFE7549B).withValues(alpha: 0.42),
                    width: 1.4,
                  ),
                ),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFE7549B),
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.018, min: 18, max: 24),
                  vertical: responsiveHeight(context, 0.012, min: 10, max: 13),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.012, min: 12, max: 16),
                  ),
                ),
                textStyle: TextStyle(
                  fontFamily: "ArabicCustomFont",
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveSize(context, 0.011, min: 13, max: 16),
                ),
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE7549B),
                backgroundColor: const Color(0xFFFFEEF4),
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.018, min: 18, max: 24),
                  vertical: responsiveHeight(context, 0.012, min: 10, max: 13),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    responsiveSize(context, 0.012, min: 12, max: 16),
                  ),
                ),
                textStyle: TextStyle(
                  fontFamily: "ArabicCustomFont",
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveSize(context, 0.011, min: 13, max: 16),
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(isMobile ? 0.92 : 1)),
            child: child!,
          ),
        ),
      );
    },
  );
}
