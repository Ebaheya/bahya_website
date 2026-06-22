import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

Future<DateTime?> customDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime now = DateTime.now();
  final isMobile = getScreenWidth(context) < 650;

  return await showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? now,
    lastDate: lastDate ?? now.add(const Duration(days: 365)),
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
                  responsiveSize(context, 0.024, min: 20, max: 28),
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
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
              headerBackgroundColor: const Color(0xFFE7549B),
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(
                  context,
                  isMobile ? 0.06 : 0.028,
                  min: 24,
                  max: 34,
                ),
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(context, 0.012, min: 13, max: 16),
                fontWeight: FontWeight.bold,
              ),
              weekdayStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(context, 0.011, min: 12, max: 14),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8A0057),
              ),
              dayStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(context, 0.011, min: 12, max: 15),
                fontWeight: FontWeight.w600,
              ),
              yearStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontSize: responsiveSize(context, 0.012, min: 13, max: 16),
                fontWeight: FontWeight.bold,
              ),
              todayForegroundColor: WidgetStateProperty.all(
                const Color(0xFFE7549B),
              ),
              todayBackgroundColor: WidgetStateProperty.all(
                const Color(0xFFFFE4F0),
              ),
              todayBorder: BorderSide(
                color: const Color(0xFFE7549B).withValues(alpha: 0.45),
              ),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }

                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey.shade400;
                }

                return const Color(0xFF272044);
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFE7549B);
                }

                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFFFEEF4);
                }

                return Colors.transparent;
              }),
              dayOverlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return const Color(0xFFE7549B).withValues(alpha: 0.12);
                }

                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFE7549B).withValues(alpha: 0.08);
                }

                return Colors.transparent;
              }),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }

                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey.shade400;
                }

                return const Color(0xFF272044);
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFE7549B);
                }

                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFFFEEF4);
                }

                return Colors.transparent;
              }),
              yearOverlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return const Color(0xFFE7549B).withValues(alpha: 0.12);
                }

                if (states.contains(WidgetState.hovered)) {
                  return const Color(0xFFE7549B).withValues(alpha: 0.08);
                }

                return Colors.transparent;
              }),
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
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
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
