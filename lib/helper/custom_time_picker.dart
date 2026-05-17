import 'package:bahya_app/helper/widgets/constant.dart';
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEA4C89),

              onPrimary: Colors.white,

              onSurface: Color(0xFF7A004C),

              surface: Colors.white,
            ),

            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,

              hourMinuteTextColor: const Color(0xFF7A004C),

              hourMinuteColor: const Color(0xFFFDE3EE),

              dialHandColor: const Color(0xFFEA4C89),

              dialBackgroundColor: const Color(0xFFFDE3EE),

              dialTextColor: const Color(0xFF7A004C),

              entryModeIconColor: const Color(0xFFEA4C89),

              dayPeriodTextColor: const Color(0xFF7A004C),

              dayPeriodColor: const Color(0xFFFDE3EE),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),

              helpTextStyle: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),

              hourMinuteTextStyle: TextStyle(
                fontSize: width * 0.09,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEA298C),

                textStyle: TextStyle(
                  fontFamily: 'ArabicCustomFont',
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.bold,
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

        prefixIcon: const Icon(Icons.access_time_outlined, color: Colors.grey),

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
