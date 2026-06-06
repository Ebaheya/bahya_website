import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';

class ScheduleFormWidget extends StatefulWidget {
  const ScheduleFormWidget({super.key});

  @override
  State<ScheduleFormWidget> createState() => _ScheduleFormWidgetState();
}

class _ScheduleFormWidgetState extends State<ScheduleFormWidget> {
  String? selectedForm;
  String repeat = "لا يتكرر";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Container(
      width: w * 0.9,
      padding: EdgeInsets.all(h * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          customText(
            text: "جدولة نشر النموذج",
            size: h * 0.03,
            bold: true,
            color: const Color(0xFF7A004C),
          ),
          SizedBox(height: h * 0.01),

          customText(
            text: "حدد النموذج والوقت المناسب للنشر",
            size: h * 0.02,
            color: const Color(0xFFE40070),
          ),
          SizedBox(height: h * 0.03),

          DropdownButtonFormField(
            decoration: fieldStyle(),
            hint: customText(
              text: "اختر نموذج من القائمة",
              size: h * 0.018,
              isCenter: false,
              bold: true,
              color: Colors.black54,
            ),
            style: TextStyle(
              fontSize: h * 0.018,
              color: const Color(0xFFE40070),
              fontFamily: "ArabicCustomFont",
              fontWeight: FontWeight.bold,
            ),
            items: ["PHQ-9", "PHQ-4", "GAD-7", "استبيان النوم"]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: customText(text: e, size: h * 0.018),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => selectedForm = v),
          ),

          SizedBox(height: h * 0.03),

          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: fieldStyle().copyWith(
                    hintText: selectedTime == null
                        ? "--:--"
                        : selectedTime!.format(context),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                  onTap: pickCustomTime,
                ),
              ),
              SizedBox(width: w * 0.03),
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: fieldStyle().copyWith(
                    hintText: selectedDate == null
                        ? "mm/dd/yyyy"
                        : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  onTap: pickCustomDate,
                ),
              ),
            ],
          ),

          SizedBox(height: h * 0.03),

          DropdownButtonFormField(
            decoration: fieldStyle(),
            value: repeat,
            items: ["لا يتكرر", "يومي", "أسبوعي", "شهري"]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: customText(text: e, size: h * 0.018),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => repeat = v!),
          ),

          SizedBox(height: h * 0.04),

          CustomGlowButton(
            title: "جدولة النشر",
            width: w * 0.5,
            onPressed: () {
              customDialog(
                context: context,
                title: "جدولة النشر",
                message: "تم جدولة نشر النموذج بنجاح.",
              );
            },
          ),
        ],
      ),
    );
  }

  InputDecoration fieldStyle() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF6EEF9),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Future pickCustomDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink[200]!,
              onPrimary: Colors.white,
              onSurface: Color(0xFF7A004C),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFFEA298C)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) setState(() => selectedDate = d);
  }

  Future pickCustomTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        final h = getScreenHeight(context);
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFFFFF1FA),

              hourMinuteColor: const Color(0xFFFFE4F4),
              hourMinuteTextColor: const Color(0xFF7A004C),

              hourMinuteTextStyle: TextStyle(
                fontSize: h * 0.04,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7A004C),
                fontFamily: "ArabicCustomFont",
              ),

              dialHandColor: const Color(0xFFFFE4F4),
              dialBackgroundColor: Colors.white,
              dialTextColor: Colors.black,
              entryModeIconColor: const Color(0xFF7A004C),

              dayPeriodColor: const Color(0xFFFFE4F4),
              dayPeriodTextColor: const Color(0xFF7A004C),
              dayPeriodBorderSide: const BorderSide(color: Color(0xFFEA298C)),
              dayPeriodTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: h * 0.018,
                fontFamily: "ArabicCustomFont",
              ),

              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEA298C),
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: Colors.grey[800],
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (t != null) setState(() => selectedTime = t);
  }
}
