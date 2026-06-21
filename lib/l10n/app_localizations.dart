import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_l10n/app_localizations_generated.dart';
import 'package:bahya_l10n/legacy_message_lookup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
export 'package:bahya_l10n/app_localizations_generated.dart';

class AppLanguageController {
  AppLanguageController._();
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier<Locale>(
    const Locale('ar'),
  );
  static void setLocale(Locale locale) {
    localeNotifier.value = locale;
    Intl.defaultLocale = locale.languageCode;
  }

  static Future<void> setLocaleAndSave(Locale locale) async {
    setLocale(locale);
    await SecureStorageService().saveLanguageCode(locale.languageCode);
  }

  static Future<void> loadSavedLocale() async {
    final savedLanguage = await SecureStorageService().getLanguageCode();
    if (savedLanguage == 'en' || savedLanguage == 'ar') {
      setLocale(Locale(savedLanguage!));
    } else {
      Intl.defaultLocale = localeNotifier.value.languageCode;
    }
  }

  static Future<void> toggle() async {
    final currentLanguage = localeNotifier.value.languageCode;
    await setLocaleAndSave(
      currentLanguage == 'ar' ? const Locale('en') : const Locale('ar'),
    );
  }
}

String localizedText(BuildContext context, String text) {
  return lookupLegacyMessage(AppLocalizations.of(context), text);
}

String localizedTextByCurrentLocale(String text) {
  return localizedTextByLocaleCode(
    AppLanguageController.localeNotifier.value.languageCode,
    text,
  );
}

String localizedTextByLocaleCode(String localeCode, String text) {
  final localizations = lookupAppLocalizations(Locale(localeCode));
  return lookupLegacyMessage(localizations, text);
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
