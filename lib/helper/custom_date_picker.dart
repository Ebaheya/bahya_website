import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:flutter/material.dart';

class CustomDatePickerField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final TextEditingController controller;
  final DateTime? initialDate;
  final Function(DateTime date)? onDateSelected;
  final double? borderRadius;
  const CustomDatePickerField({
    super.key,
    this.labelText,
    required this.hintText,
    required this.controller,
    this.initialDate,
    this.onDateSelected,
    this.borderRadius,
  });

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  Future<void> pickDate() async {
    double width = getScreenWidth(context);

    final pickedDate = await showDatePicker(
      context: context,

      initialDate: widget.initialDate ?? DateTime.now(),

      firstDate: DateTime(1950),

      lastDate: DateTime.now(),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFEA4C89),

              onPrimary: Colors.white,

              onSurface: const Color(0xFF7A004C),

              surface: Colors.white,
            ),

            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),

            textTheme: TextTheme(
              headlineLarge: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),

              headlineMedium: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),

              bodyLarge: TextStyle(
                fontSize: width * 0.04,
                color: const Color(0xFF7A004C),
                fontFamily: 'ArabicCustomFont',
              ),

              bodyMedium: TextStyle(
                fontSize: width * 0.04,
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
    double width = getScreenWidth(context);

    return TextFormField(
      controller: widget.controller,

      readOnly: true,

      onTap: pickDate,

      keyboardType: TextInputType.datetime,

      style: TextStyle(
        color: Colors.black,
        fontSize: width * 0.04,
        fontFamily: 'ArabicCustomFont',
      ),

      decoration: InputDecoration(
        alignLabelWithHint: true,

        hintText: widget.hintText,

        labelText: widget.labelText,
        prefixIcon: Icon(Icons.calendar_today, color: iconColor),

        labelStyle: TextStyle(
          color: Colors.black,
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
          borderRadius: BorderRadius.circular(8.0),

          borderSide: const BorderSide(color: Colors.grey, width: 1.2),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 30),

          borderSide: const BorderSide(color: Color(0xFFFF7BB0), width: 1.5),
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
