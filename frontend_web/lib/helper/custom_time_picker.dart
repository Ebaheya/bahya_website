import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

Future<TimeOfDay?> customTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
}) async {
  return await showTimePicker(
    context: context,
    initialTime: initialTime ?? TimeOfDay.now(),
    builder: (context, child) {
      final h = getScreenHeight(context);

      return Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: "ArabicCustomFont"),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF8A1DB3),
            onPrimary: Colors.white,
            surface: Color(0xFFFFF7FD),
            onSurface: Color(0xFF2B2B2B),
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: const Color(0xFFFFF7FD),
            helpTextStyle: TextStyle(
              fontFamily: "ArabicCustomFont",
              fontSize: h * 0.018,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8A1DB3),
            ),
            hourMinuteColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF8A1DB3);
              }
              return const Color(0xFFF3E8FA);
            }),
            hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return const Color(0xFF4D2A84);
            }),
            hourMinuteTextStyle: TextStyle(
              fontFamily: "ArabicCustomFont",
              fontSize: h * 0.055,
              fontWeight: FontWeight.bold,
            ),
            dialBackgroundColor: const Color(0xFFF6EEF9),
            dialHandColor: const Color(0xFF8A1DB3),
            dialTextColor: const Color(0xFF2B2B2B),
            dayPeriodColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFFFFD6EA);
              }
              return Colors.white;
            }),
            dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFFE5007D);
              }
              return const Color(0xFF555555);
            }),
            dayPeriodBorderSide: const BorderSide(color: Color(0xFFE5007D)),
            dayPeriodTextStyle: TextStyle(
              fontFamily: "ArabicCustomFont",
              fontSize: h * 0.017,
              fontWeight: FontWeight.bold,
            ),
            entryModeIconColor: const Color(0xFF8A1DB3),
            confirmButtonStyle: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE5007D),
              textStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontWeight: FontWeight.bold,
                fontSize: h * 0.016,
              ),
            ),
            cancelButtonStyle: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE5007D),
              textStyle: TextStyle(
                fontFamily: "ArabicCustomFont",
                fontWeight: FontWeight.bold,
                fontSize: h * 0.016,
              ),
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}
