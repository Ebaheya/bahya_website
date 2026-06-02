import 'package:bahya_app/helper/constant.dart';
import 'package:flutter/material.dart';

class CustomTimePickerField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final TextEditingController controller;
  final Function(TimeOfDay time)? onTimeSelected;
  final double? borderRadius;
  const CustomTimePickerField({
    super.key,
    this.labelText,
    required this.hintText,
    required this.controller,
    this.onTimeSelected,
    this.borderRadius,
  });

  @override
  State<CustomTimePickerField> createState() => _CustomTimePickerFieldState();
}

class _CustomTimePickerFieldState extends State<CustomTimePickerField> {
  Future<void> pickTime() async {
    double width = getScreenWidth(context);

    final pickedTime = await showTimePicker(
      context: context,

      initialTime: TimeOfDay.now(),

      builder: (context, child) {
        return  Theme(
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
                fontSize: width * 0.018,
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
                fontSize: width * 0.055,
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
                fontSize: width * 0.017,
                fontWeight: FontWeight.bold,
              ),
              entryModeIconColor: const Color(0xFF8A1DB3),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5007D),
                textStyle: TextStyle(
                  fontFamily: "ArabicCustomFont",
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.016,
                ),
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5007D),
                textStyle: TextStyle(
                  fontFamily: "ArabicCustomFont",
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.016,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formattedTime =
          "${pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod}:${pickedTime.minute.toString().padLeft(2, '0')} ${pickedTime.period == DayPeriod.am ? "AM" : "PM"}";

      widget.controller.text = formattedTime;

      widget.onTimeSelected?.call(pickedTime);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = getScreenWidth(context);

    return TextFormField(
      controller: widget.controller,

      readOnly: true,

      onTap: pickTime,

      style: TextStyle(
        color: Colors.black,
        fontSize: width * 0.04,
        fontFamily: 'ArabicCustomFont',
      ),

      decoration: InputDecoration(
        alignLabelWithHint: true,

        hintText: widget.hintText,

        labelText: widget.labelText,

        prefixIcon: Icon(Icons.access_time_outlined, color: iconColor),

        labelStyle: TextStyle(
          color: Colors.grey,
          fontSize: width * 0.04,
          fontFamily: 'ArabicCustomFont',
        ),

        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: width * 0.04,
          fontFamily: 'ArabicCustomFont',
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 30),

          borderSide: const BorderSide(color: Color(0xFFFFC1D9), width: 1.2),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 30),

          borderSide: const BorderSide(color: Color(0xFFFF7BB0), width: 1.2),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 30),

          borderSide: const BorderSide(color: Color(0xFFFF7BB0), width: 1.5),
        ),

        errorStyle: TextStyle(
          fontFamily: 'ArabicCustomFont',
          fontSize: width * 0.04,
        ),
      ),
    );
  }
}
