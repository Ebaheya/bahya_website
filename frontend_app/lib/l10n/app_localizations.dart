import 'dart:convert';

import 'package:bahya_app/data/local/data_secure.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/l10n/article_localizations.dart';
import 'package:bahya_app/l10n/common_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> load() async {
    final code = await SecureStorageService().getLocaleCode();
    _locale = Locale(code == 'en' ? 'en' : 'ar');
    intl.Intl.defaultLocale = _locale.languageCode;
    notifyListeners();
  }

  Future<void> toggle() async {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    intl.Intl.defaultLocale = _locale.languageCode;
    await SecureStorageService().saveLocaleCode(_locale.languageCode);
    notifyListeners();
  }
}

final LocaleNotifier localeNotifier = LocaleNotifier();

bool _isChangingLanguage = false;

Future<void> changeLanguageWithLoading(BuildContext context) async {
  if (_isChangingLanguage) return;
  _isChangingLanguage = true;

  final overlay = Overlay.of(context, rootOverlay: true);
  final entry = OverlayEntry(
    builder: (_) => Material(
      color: Colors.white,
      child: Center(child: customLoading()),
    ),
  );

  overlay.insert(entry);

  try {
    await Future.delayed(const Duration(seconds: 2));
    await localeNotifier.toggle();
  } finally {
    entry.remove();
    _isChangingLanguage = false;
  }
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  String t(String text) {
    final normalized = _normalizeArabic(text);
    if (isArabic) {
      return commonArabic[normalized] ?? articleArabic[normalized] ?? normalized;
    }
    return commonEnglish[normalized] ?? articleEnglish[normalized] ?? normalized;
  }

  static String _normalizeArabic(String text) {
    if (text.isEmpty || text.startsWith('article.')) return text;

    try {
      return utf8.decode(latin1.encode(text));
    } catch (_) {
      return text;
    }
  }
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String text) => l10n.t(text);
  TextDirection get appTextDirection => l10n.textDirection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    intl.Intl.defaultLocale = locale.languageCode;
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
