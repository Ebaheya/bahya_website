import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class CustomDatePickerField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final TextEditingController controller;
  final DateTime? initialDate;
  final Function(DateTime date)? onDateSelected;
  final bool showCalendarIcon;
  final bool bordered;
  const CustomDatePickerField({
    super.key,
    this.labelText,
    required this.hintText,
    required this.controller,
    this.initialDate,
    this.onDateSelected,
    this.showCalendarIcon = true,
    this.bordered = false,
  });

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  double responsiveSize(
    BuildContext context,
    double factor, {
    double min = 10,
    double max = 24,
  }) {
    final width = getScreenWidth(context);
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;

    final value = width * factor;

    if (shortestSide < 600) {
      return value.clamp(min, max * 0.9);
    }

    return value.clamp(min, max);
  }

  double responsiveHeight(
    BuildContext context,
    double factor, {
    double min = 8,
    double max = 80,
  }) {
    final height = getScreenHeight(context);
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;

    final value = height * factor;

    if (shortestSide < 600) {
      return value.clamp(min, max * 0.85);
    }

    return value.clamp(min, max);
  }

  Future<void> pickDate() async {
    final titleSize = responsiveSize(context, 0.025, min: 18, max: 24);
    final bodySize = responsiveSize(context, 0.018, min: 13, max: 16);
    final buttonSize = responsiveSize(context, 0.018, min: 13, max: 16);
    final radius = responsiveSize(context, 0.03, min: 18, max: 24);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEA4C89),
              onPrimary: Colors.white,
              onSurface: Color(0xFF7A004C),
              surface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),
              headlineMedium: TextStyle(
                fontSize: bodySize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),
              bodyLarge: TextStyle(
                fontSize: bodySize,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),
              bodyMedium: TextStyle(
                fontSize: bodySize,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEA298C),
                textStyle: TextStyle(
                  fontFamily: 'ArabicCustomFont',
                  fontSize: buttonSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFFEA298C)),
            dividerTheme: const DividerThemeData(
              color: Color(0xFFE9B4CB),
              thickness: 1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      widget.controller.text =
          "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";

      widget.onDateSelected?.call(pickedDate);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final textSize = responsiveSize(context, 0.018, min: 13, max: 16);
    final hintSize = responsiveSize(context, 0.017, min: 12, max: 15);
    final radius = responsiveSize(context, 0.018, min: 10, max: 14);
    final iconSize = responsiveSize(context, 0.024, min: 20, max: 24);

    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      onTap: pickDate,
      keyboardType: TextInputType.datetime,
      style: TextStyle(
        color: Colors.black,
        fontSize: textSize,
        fontFamily: 'ArabicCustomFont',
      ),
      decoration: InputDecoration(
        alignLabelWithHint: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        suffixIcon: widget.showCalendarIcon
            ? Icon(Icons.calendar_today, color: Colors.grey, size: iconSize)
            : null,
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: textSize,
          fontFamily: 'ArabicCustomFont',
        ),
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: hintSize,
          fontFamily: 'ArabicCustomFont',
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: responsiveHeight(context, 0.016, min: 12, max: 16),
          horizontal: responsiveSize(context, 0.018, min: 12, max: 16),
        ),
        // filled: true,
        fillColor: Colors.white,
        border: widget.bordered
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: const BorderSide(color: Colors.grey, width: 1.2),
              )
            : InputBorder.none,

        enabledBorder: widget.bordered
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(color: Colors.pink[300]!, width: 1.2),
              )
            : InputBorder.none,

        focusedBorder: widget.bordered
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: const BorderSide(color: Colors.pink, width: 1.5),
              )
            : InputBorder.none,

        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    );
  }
}
