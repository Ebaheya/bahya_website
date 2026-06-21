import 'package:bahya_app/route.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/services/push_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.instance.initialize();

  authNotifier.addListener(() {
    PushNotificationService.instance.registerDeviceTokenIfLoggedIn();
  });

  await localeNotifier.load();
  await authNotifier.checkLogin();
  await PushNotificationService.instance.registerDeviceTokenIfLoggedIn();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeNotifier,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          locale: localeNotifier.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: context.appTextDirection,
              child: child ?? const SizedBox.shrink(),
            );
          },
          initialRoute: '/splash',
          onGenerateRoute: AppRoute().generateRoute,
        );
      },
    );
  }
}
