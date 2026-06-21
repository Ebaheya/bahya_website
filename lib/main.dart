import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:bahya_website/platform/url_strategy.dart';
import 'package:bahya_website/route.dart';
import 'package:bahya_website/service/login_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();
  initDio();
  await AppLanguageController.loadSavedLocale();

  authNotifier.checkLogin();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
