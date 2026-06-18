import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CustomDatePickerField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime? firstAllowedDate;
  final DateTime? lastAllowedDate;
  final Function(DateTime date)? onDateSelected;
  final double? borderRadius;

  const CustomDatePickerField({
    super.key,
    this.labelText,
    required this.hintText,
    required this.controller,
    this.initialDate,
    this.firstAllowedDate,
    this.lastAllowedDate,
    this.onDateSelected,
    this.borderRadius,
  });

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> pickDate() async {
    final today = _dateOnly(DateTime.now());

    final firstDate = _dateOnly(widget.firstAllowedDate ?? DateTime(1950));

    final lastDate = _dateOnly(
      widget.lastAllowedDate ?? today.add(const Duration(days: 3650)),
    );

    DateTime initialDate = _dateOnly(widget.initialDate ?? today);

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (date) {
        final d = _dateOnly(date);
        return !d.isBefore(firstDate) && !d.isAfter(lastDate);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(
              context,
            ).textTheme.apply(fontFamily: 'ArabicCustomFont'),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8A1DB3),
              onPrimary: Colors.white,
              surface: Color(0xFFFFF7FD),
              onSurface: Color(0xFF2B2B2B),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: const Color(0xFFFFF7FD),
              headerBackgroundColor: const Color(0xFF8A1DB3),
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey.shade400;
                }
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF2B2B2B);
              }),
              dayBackgroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF8A1DB3);
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFFE5007D);
              }),
              todayBorder: const BorderSide(color: Color(0xFFE5007D)),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5007D),
                textStyle: TextStyle(
                  fontFamily: 'ArabicCustomFont',
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveSize(context, 0.032, min: 12, max: 16),
                ),
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5007D),
                textStyle: TextStyle(
                  fontFamily: 'ArabicCustomFont',
                  fontWeight: FontWeight.bold,
                  fontSize: responsiveSize(context, 0.032, min: 12, max: 16),
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                getScreenWidth(context) < 380 ? 0.92 : 1,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (pickedDate != null) {
      widget.controller.text =
          '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';

      widget.onDateSelected?.call(pickedDate);

      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ?? responsiveSize(context, 0.08, min: 18, max: 30);

    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      onTap: pickDate,
      keyboardType: TextInputType.datetime,
      style: TextStyle(
        color: Colors.black,
        fontSize: responsiveSize(context, 0.04, min: 14, max: 18),
        fontFamily: 'ArabicCustomFont',
      ),
      decoration: InputDecoration(
        alignLabelWithHint: true,
        hintText: context.tr(widget.hintText),
        labelText: widget.labelText == null
            ? null
            : context.tr(widget.labelText!),
        prefixIcon: Icon(
          Icons.calendar_today,
          color: iconColor,
          size: responsiveSize(context, 0.055, min: 20, max: 26),
        ),
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: responsiveSize(context, 0.038, min: 13, max: 17),
          fontFamily: 'ArabicCustomFont',
        ),
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: responsiveSize(context, 0.038, min: 13, max: 17),
          fontFamily: 'ArabicCustomFont',
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: responsiveHeight(context, 0.016, min: 12, max: 16),
          horizontal: responsiveSize(context, 0.035, min: 12, max: 18),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Colors.grey, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xFFFF7BB0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: Color(0xFFFF7BB0), width: 1.5),
        ),
        errorStyle: TextStyle(
          fontFamily: 'ArabicCustomFont',
          fontSize: responsiveSize(context, 0.032, min: 11, max: 14),
        ),
      ),
    );
  }
}
