part of 'schedule_form_widget.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        return Column(
          children: [
            Icon(
              Icons.publish_rounded,
              color: const Color(0xFFE40070),
              size: responsiveSize(context, 0.04, min: 34, max: 56),
            ),
            SizedBox(height: responsiveHeight(context, 0.02, min: 12, max: 20)),
            customText(
              text: "نشر النموذج",
              size: responsiveSize(context, 0.025, min: 22, max: 34),
              bold: true,
              color: textColor,
              isEnglish: locale.languageCode == 'en',
            ),
          ],
        );
      },
    );
  }
}

class ScheduleDateTimeRow extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const ScheduleDateTimeRow({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        final timeField = Column(
          crossAxisAlignment: isEnglish
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            scheduleLabel(context: context, title: "وقت النشر"),
            SizedBox(height: responsiveHeight(context, 0.02, min: 12, max: 20)),
            schedulePickerField(
              context: context,
              text: selectedTime == null
                  ? "اختياري"
                  : selectedTime!.format(context),
              icon: Icons.access_time_rounded,
              onTap: onPickTime,
            ),
          ],
        );

        final dateField = Column(
          crossAxisAlignment: isEnglish
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            scheduleLabel(context: context, title: "تاريخ النشر"),
            SizedBox(height: responsiveHeight(context, 0.02, min: 12, max: 20)),
            schedulePickerField(
              context: context,
              text: selectedDate == null
                  ? "اختياري"
                  : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
              icon: Icons.calendar_month_rounded,
              onTap: onPickDate,
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: isEnglish
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              timeField,
              SizedBox(
                height: responsiveHeight(context, 0.025, min: 18, max: 24),
              ),
              dateField,
            ],
          );
        }

        return Row(
          textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
          children: [
            Expanded(child: timeField),
            SizedBox(width: responsiveSize(context, 0.045, min: 28, max: 70)),
            Expanded(child: dateField),
          ],
        );
      },
    );
  }
}
