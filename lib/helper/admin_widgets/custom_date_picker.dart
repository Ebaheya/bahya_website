import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
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
  bool _focused = false;

  String _localized(String text) {
    return localizedTextByLocaleCode(
      Localizations.localeOf(context).languageCode,
      text,
    );
  }

  Future<void> pickDate() async {
    final isMobile = getScreenWidth(context) < 650;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE7549B),
                  backgroundColor: const Color(0xFFFFEEF4),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(
                      context,
                      0.018,
                      min: 18,
                      max: 24,
                    ),
                    vertical: responsiveHeight(
                      context,
                      0.012,
                      min: 10,
                      max: 13,
                    ),
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

    if (pickedDate == null) return;

    widget.controller.text =
        "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";

    widget.onDateSelected?.call(pickedDate);

    if (mounted) setState(() {});
  }

  Widget? _calendarIcon(BuildContext context) {
    if (!widget.showCalendarIcon) return null;

    return Padding(
      padding: EdgeInsets.all(responsiveSize(context, 0.005, min: 6, max: 8)),
      child: Container(
        width: responsiveSize(context, 0.02, min: 28, max: 34),
        height: responsiveSize(context, 0.02, min: 28, max: 34),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.pink.shade100.withValues(alpha: 0.5),
        ),
        child: Icon(
          Icons.calendar_month_rounded,
          color: const Color(0xFFE7549B),
          size: responsiveSize(context, 0.014, min: 18, max: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglishLocale =
        Localizations.localeOf(context).languageCode == 'en';
    final effectiveDirection = isEnglishLocale
        ? TextDirection.ltr
        : TextDirection.rtl;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(
        widget.bordered ? responsiveSize(context, 0.004, min: 4, max: 6) : 0,
      ),
      decoration: BoxDecoration(
        color: widget.bordered ? const Color(0xFFFEFBFD) : Colors.transparent,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 16, max: 22),
        ),
        border: widget.bordered
            ? Border.all(
                color: _focused
                    ? const Color(0xFFE7549B).withValues(alpha: 0.42)
                    : const Color(0xFFE7549B).withValues(alpha: 0.12),
                width: _focused ? 1.4 : 1,
              )
            : null,
      ),
      child: Focus(
        onFocusChange: (value) => setState(() => _focused = value),
        child: TextFormField(
          controller: widget.controller,
          readOnly: true,
          onTap: pickDate,
          keyboardType: TextInputType.datetime,
          textDirection: effectiveDirection,
          textAlign: effectiveDirection == TextDirection.ltr
              ? TextAlign.left
              : TextAlign.right,
          style: TextStyle(
            color: Colors.black,
            fontSize: responsiveSize(context, 0.0075, min: 12, max: 15),
            fontFamily: 'ArabicCustomFont',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.bordered
                ? Colors.white.withValues(alpha: 0.82)
                : Colors.transparent,
            alignLabelWithHint: true,
            counterText: '',
            suffixIcon: _calendarIcon(context),
            suffixIconConstraints: BoxConstraints(
              maxHeight: responsiveHeight(context, 0.08, min: 50, max: 100),
              maxWidth: responsiveSize(context, 0.06, min: 50, max: 100),
            ),
            hintText: _localized(widget.hintText),
            labelText: widget.labelText == null
                ? null
                : _localized(widget.labelText!),
            hintTextDirection: effectiveDirection,
            labelStyle: TextStyle(
              color: _focused ? const Color(0xFFE7549B) : Colors.black87,
              fontSize: responsiveSize(context, 0.008, min: 12, max: 16),
              fontFamily: 'ArabicCustomFont',
              fontWeight: FontWeight.w600,
            ),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: responsiveSize(context, 0.008, min: 12, max: 16),
              fontFamily: 'ArabicCustomFont',
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: responsiveHeight(context, 0.015, min: 12, max: 16),
              horizontal: responsiveSize(context, 0.010, min: 12, max: 16),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.010, min: 12, max: 16),
              ),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.010, min: 12, max: 16),
              ),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.010, min: 12, max: 16),
              ),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.010, min: 12, max: 16),
              ),
              borderSide: BorderSide.none,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.010, min: 12, max: 16),
              ),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(fontSize: 0, height: 0),
            errorMaxLines: 1,
          ),
        ),
      ),
    );
  }
}
