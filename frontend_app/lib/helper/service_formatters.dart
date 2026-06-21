import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

String formatServiceDate(BuildContext context, String value) {
  if (value.trim().isEmpty) return '-';

  final parsed = DateTime.tryParse(value);
  if (parsed == null) return context.tr(value);

  if (!context.l10n.isArabic) {
    return intl.DateFormat('EEEE, d MMMM y', 'en').format(parsed);
  }

  const weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  return '${weekdays[parsed.weekday - 1]}، ${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}

String formatServiceTime(BuildContext context, String value) {
  if (value.trim().isEmpty) return '-';

  final parts = value.split(':');
  if (parts.length < 2) return context.tr(value);

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return context.tr(value);

  final date = DateTime(2024, 1, 1, hour, minute);
  final formatted = intl.DateFormat('h:mm a', 'en').format(date);

  if (!context.l10n.isArabic) return formatted;

  return formatted.replaceAll('AM', 'صباحًا').replaceAll('PM', 'مساءً');
}

String formatSeatsAvailable(BuildContext context, int seats) {
  if (context.l10n.isArabic) return 'متاح $seats مقعد';
  return '$seats seats available';
}
