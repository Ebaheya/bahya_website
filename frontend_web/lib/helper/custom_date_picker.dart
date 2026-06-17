import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

Future<DateTime?> customDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime now = DateTime.now();

  return await showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? now,
    lastDate: lastDate ?? now.add(const Duration(days: 365)),
    builder: (context, child) {
      final h = getScreenHeight(context);

      return Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(
            context,
          ).textTheme.apply(fontFamily: "ArabicCustomFont"),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF7B1FA2),
            onPrimary: Colors.white,
            surface: Color(0xFFFFF7FD),
            onSurface: Color(0xFF2B2B2B),
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: const Color(0xFFFFF7FD),
            headerBackgroundColor: const Color(0xFF7B1FA2),
            headerForegroundColor: Colors.white,
            todayForegroundColor: WidgetStateProperty.all(
              const Color(0xFFE5007D),
            ),
            todayBackgroundColor: WidgetStateProperty.all(
              const Color(0xFFFFD6EA),
            ),
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return const Color(0xFF2B2B2B);
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF7B1FA2);
              }
              return Colors.transparent;
            }),
            yearForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return const Color(0xFF2B2B2B);
            }),
            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF7B1FA2);
              }
              return Colors.transparent;
            }),
            headerHeadlineStyle: TextStyle(
              fontFamily: "ArabicCustomFont",
              fontSize: h * 0.032,
              fontWeight: FontWeight.bold,
            ),
            headerHelpStyle: TextStyle(
              fontFamily: "ArabicCustomFont",
              fontSize: h * 0.016,
              fontWeight: FontWeight.bold,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
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
