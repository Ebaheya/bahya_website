import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated localizations preserve English and Arabic messages', () {
    final english = lookupAppLocalizations(const Locale('en'));
    final arabic = lookupAppLocalizations(const Locale('ar'));

    expect(english.signIn, 'Sign in');
    expect(arabic.signIn, 'تسجيل الدخول');
    expect(english.patientInformation, 'Patient information');
    expect(arabic.patientInformation, 'معلومات المريض');
  });

  test('generated localization formats parameterized messages', () {
    final english = lookupAppLocalizations(const Locale('en'));
    final arabic = lookupAppLocalizations(const Locale('ar'));

    expect(
      english.showingFromToToOfTotalUsers(1, 10, 25),
      'Showing 1 to 10 of 25 users',
    );
    expect(
      arabic.showingFromToToOfTotalUsers(1, 10, 25),
      'عرض 1 إلى 10 من إجمالي 25 مستخدم',
    );
  });

  test('legacy visible text lookup delegates to generated ARB messages', () {
    expect(localizedTextByLocaleCode('en', 'تسجيل الدخول'), 'Sign in');
    expect(localizedTextByLocaleCode('ar', 'Sign in'), 'تسجيل الدخول');
  });
}
