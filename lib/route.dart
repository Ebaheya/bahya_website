import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/screens/add_questionnaire.dart';
import 'package:bahya_website/screens/admin/admin_panal.dart';
import 'package:bahya_website/screens/home.dart';
import 'package:bahya_website/screens/login.dart';
import 'package:bahya_website/screens/patient_info.dart';
import 'package:bahya_website/screens/publish_schedule_screen.dart';
import 'package:bahya_website/screens/questionnaire_filler.dart';
import 'package:bahya_website/screens/reset_password.dart';
import 'package:bahya_website/screens/volunteer_survey_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _passwordResetDone = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get passwordResetDone => _passwordResetDone;
  bool get isLoading => _isLoading;
Future<void> forceLogout() async {
    final storage = SecureStorageService();
    await storage.clearTokens();

    _isLoggedIn = false;
    _isLoading = false;

    notifyListeners();
  }
Future<void> checkLogin() async {
    _isLoading = true;
    notifyListeners();

    final storage = SecureStorageService();

    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();

    _isLoggedIn =
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;

    _isLoading = false;
    notifyListeners();
  }

  void login() {
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final storage = SecureStorageService();
    await storage.clearTokens();

    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completePasswordReset() async {
    _isLoading = true;
    notifyListeners();

    final storage = SecureStorageService();
    await storage.clearTokens();

    _isLoggedIn = false;
    _passwordResetDone = true;

    _isLoading = false;
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
    initialLocation: '/loading',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final currentPath = state.matchedLocation;

      final isLoadingPage = currentPath == '/loading';
      final isLoginPage = currentPath == '/login';
      final isResetPasswordPage = currentPath == '/reset-password';

      if (authNotifier.isLoading) {
        return isLoadingPage ? null : '/loading';
      }

      if (isLoadingPage) {
        return authNotifier.isLoggedIn ? '/home' : '/login';
      }

      if (isResetPasswordPage) {
        return null;
      }

      if (!authNotifier.isLoggedIn && !isLoginPage) {
        return '/login';
      }

      if (authNotifier.isLoggedIn && isLoginPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) {
          return Scaffold(body: Center(child: customLoading()));
        },
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          if (authNotifier.passwordResetDone) {
            authNotifier.clearPasswordReset();
          }
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

      GoRoute(path: '/admin', builder: (context, state) => AdminPanelPage()),

      GoRoute(path: '/home', builder: (context, state) => HomePage()),

      GoRoute(
        path: '/patient_info',
        builder: (context, state) => PatientInfo(),
      ),

      GoRoute(
        path: '/add_questionnaire',
        builder: (context, state) => AddQuestionnaire(),
      ),

      GoRoute(
        path: '/publish_schedule',
        builder: (context, state) => PublishScheduleScreen(),
      ),

      GoRoute(
        path: '/questionnaire_filler',
        builder: (context, state) => FormsScreen(),
      ),

      GoRoute(
        path: '/volunteer_survey',
        builder: (context, state) => VolunteerPatientsScreen(),
      ),
    ],
  );
}
