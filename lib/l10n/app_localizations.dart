import 'package:bahya_website/l10n/ar_to_en.dart';
import 'package:bahya_website/l10n/en_to_ar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class AppLanguageController {
  AppLanguageController._();

  static final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(
    const Locale('ar'),
  );

  static void setLocale(Locale locale) {
    localeNotifier.value = locale;
    Intl.defaultLocale = locale.languageCode;
  }

  static void toggle() {
    final currentLanguage = localeNotifier.value.languageCode;
    setLocale(
      currentLanguage == 'ar' ? const Locale('en') : const Locale('ar'),
    );
  }
}

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const supportedLocales = [Locale('ar'), Locale('en')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isEnglish => locale.languageCode == 'en';

  String translate(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return text;
    }

    final map = isEnglish ? arToEn : enToAr;
    final exact = map[normalized];
    if (exact != null) return exact;

    var translated = normalized;
    final entries = map.entries.where((entry) => entry.key.length > 2).toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in entries) {
      if (translated.contains(entry.key)) {
        translated = translated.replaceAll(entry.key, entry.value);
      }
    }
    return translated;
  }

  static String translateByLocaleCode(String localeCode, String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return text;
    }

    final languageCode = localeCode.split('_').first;
    final map = languageCode == 'en' ? arToEn : enToAr;
    final exact = map[normalized];
    if (exact != null) return exact;

    var translated = normalized;
    final entries = map.entries.where((entry) => entry.key.length > 2).toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in entries) {
      if (translated.contains(entry.key)) {
        translated = translated.replaceAll(entry.key, entry.value);
      }
    }
    return translated;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    Intl.defaultLocale = locale.languageCode;
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

String localizedText(BuildContext context, String text) {
  return AppLocalizations.of(context).translate(text);
}

String localizedTextByCurrentLocale(String text) {
  return AppLocalizations.translateByLocaleCode(
    AppLanguageController.localeNotifier.value.languageCode,
    text,
  );
}

const flutterLocalizationDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

