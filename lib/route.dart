import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/screens/add_questionnaire.dart';
import 'package:bahya_website/screens/admin_panel/admin_panal.dart';
import 'package:bahya_website/screens/home.dart';
import 'package:bahya_website/screens/login.dart';
import 'package:bahya_website/screens/patient_info.dart';
import 'package:bahya_website/screens/profile_widget.dart';
import 'package:bahya_website/screens/publish_schedule_screen.dart';
import 'package:bahya_website/screens/questionnaire_filler.dart';
import 'package:bahya_website/screens/reset_password.dart';
import 'package:bahya_website/screens/volunteer_survey_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool _passwordResetDone = false;

  bool get isLoggedIn => _isLoggedIn;

  bool get passwordResetDone => _passwordResetDone;

  //////////////////////////////////////////////////////
  /// Check saved token
  //////////////////////////////////////////////////////

  Future<void> checkLogin() async {
    final storage = SecureStorageService();

    final token = await storage.getAccessToken();

    _isLoggedIn = token != null && token.isNotEmpty;

    notifyListeners();
  }


  void login() {
    _isLoggedIn = true;

    notifyListeners();
  }


  void logout() {
    _isLoggedIn = false;

    notifyListeners();
  }


  void completePasswordReset() {
    _passwordResetDone = true;

    notifyListeners();
  }

  void clearPasswordReset() {
    _passwordResetDone = false;

    notifyListeners();
  }
}
final AuthNotifier authNotifier = AuthNotifier();

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',

    refreshListenable: authNotifier,

    redirect: (context, state) {
      final loggedIn = authNotifier.isLoggedIn;

      final passwordResetDone = authNotifier.passwordResetDone;

      final currentPath = state.matchedLocation;

      final isLoginPage = currentPath == '/login';

      final isResetPasswordPage = currentPath == '/reset-password';


      if (passwordResetDone && isResetPasswordPage) {
        return '/login';
      }


      if (!loggedIn && !isLoginPage && !isResetPasswordPage) {
        return '/login';
      }


      if (loggedIn && (isLoginPage || isResetPasswordPage)) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',

        builder: (context, state) {
          return LoginPage();
        },
      ),
      GoRoute(
        path: '/reset-password',

        builder: (context, state) {
          final token = state.uri.queryParameters['token'];

          if (token == null || token.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Invalid reset token')),
            );
          }

          return ResetPassword(token: token);
        },
      ),

      GoRoute(
        path: '/admin',

        builder: (context, state) {
          return AdminPanelPage();
        },
      ),

      GoRoute(
        path: '/home',

        builder: (context, state) {
          return HomePage();
        },
      ),

      GoRoute(
        path: '/patient_info',

        builder: (context, state) {
          return PatientInfo();
        },
      ),

      GoRoute(
        path: '/add_questionnaire',

        builder: (context, state) {
          return AddQuestionnaire();
        },
      ),

      GoRoute(
        path: '/publish_schedule',

        builder: (context, state) {
          return PublishScheduleScreen();
        },
      ),

      GoRoute(
        path: '/questionnaire_filler',

        builder: (context, state) {
          return FormsScreen();
        },
      ),

      GoRoute(
        path: '/volunteer_survey',

        builder: (context, state) {
          return VolunteerPatientsScreen();
        },
      ),
    ],
  );
}
