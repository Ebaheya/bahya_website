import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/screens/doctor/add_questionnaire.dart';
import 'package:bahya_website/screens/admin/admin_panal.dart';
import 'package:bahya_website/screens/doctor/doctor_home.dart';
import 'package:bahya_website/screens/doctor/home.dart';
import 'package:bahya_website/screens/login.dart';
import 'package:bahya_website/screens/doctor/patients_info.dart';
import 'package:bahya_website/screens/doctor/publish_schedule_screen.dart';
import 'package:bahya_website/screens/doctor/questionnaire_filler.dart';
import 'package:bahya_website/screens/reset_password.dart';
import 'package:bahya_website/screens/volunteer_survey_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _passwordResetDone = false;
  bool _isLoading = true;
  String? _role;

  bool get isLoggedIn => _isLoggedIn;
  bool get passwordResetDone => _passwordResetDone;
  bool get isLoading => _isLoading;
  String? get role => _role;

  bool get isAdmin => _role == 'ADMIN';
  bool get isDoctor => _role == 'DOCTOR';
  bool get isVolunteer => _role == 'VOLUNTEER';

  bool _isActiveUser(Object? rawValue) {
    if (rawValue is bool) return rawValue;
    if (rawValue is num) return rawValue == 1;
    if (rawValue is String) {
      final value = rawValue.toLowerCase().trim();
      return value == 'true' || value == 'active';
    }

    return false;
  }

  String get homePath {
    if (isAdmin) return '/admin';
    if (isDoctor) return '/home';
    if (isVolunteer) return '/volunteer_survey';
    return '/login';
  }

  Future<void> forceLogout() async {
    final storage = SecureStorageService();
    await storage.clearTokens();

    _isLoggedIn = false;
    _isLoading = false;
    _role = null;

    notifyListeners();
  }

  Future<void> checkLogin() async {
    _isLoading = true;
    notifyListeners();

    final storage = SecureStorageService();

    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();

    final hasTokens =
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;

    if (!hasTokens) {
      _isLoggedIn = false;
      _role = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final userInfo = await WebService().getUserInfo();
      final user = userInfo['user'] is Map ? userInfo['user'] : userInfo;
      final role = user['role']?.toString();
      final isActive = _isActiveUser(
        user['isActive'] ??
            user['active'] ??
            user['is_active'] ??
            user['status'],
      );

      if ((role == 'ADMIN' || role == 'DOCTOR' || role == 'VOLUNTEER') &&
          isActive) {
        _role = role;
        _isLoggedIn = true;
      } else {
        await storage.clearTokens();
        _role = null;
        _isLoggedIn = false;
      }
    } catch (_) {
      await storage.clearTokens();
      _role = null;
      _isLoggedIn = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  void login({required String role}) {
    _role = role;
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
    _role = null;
    _isLoading = false;

    notifyListeners();
  }

  Future<void> completePasswordReset() async {
    _isLoading = true;
    notifyListeners();

    final storage = SecureStorageService();
    await storage.clearTokens();

    _isLoggedIn = false;
    _role = null;
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

      final adminRoutes = <String>{'/admin'};

final doctorRoutes = <String>{
        '/home',
        '/patient_info',
        '/add_questionnaire',
        '/publish_schedule',
        '/questionnaire_filler',
        '/doctor_dashboard',
      };

      final volunteerRoutes = <String>{
        '/volunteer_survey',
        '/questionnaire_filler',
      };

      if (authNotifier.isLoading) {
        return isLoadingPage ? null : '/loading';
      }

      if (isLoadingPage) {
        return authNotifier.isLoggedIn ? authNotifier.homePath : '/login';
      }

      if (isResetPasswordPage) {
        return null;
      }

      if (!authNotifier.isLoggedIn) {
        return isLoginPage ? null : '/login';
      }

      if (authNotifier.isLoggedIn && isLoginPage) {
        return authNotifier.homePath;
      }

      if (authNotifier.isAdmin) {
        return adminRoutes.contains(currentPath) ? null : '/admin';
      }

      if (authNotifier.isDoctor) {
        return doctorRoutes.contains(currentPath) ? null : '/home';
      }

      if (authNotifier.isVolunteer) {
        return volunteerRoutes.contains(currentPath)
            ? null
            : '/volunteer_survey';
      }

      return '/login';
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
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];

          if (token == null || token.isEmpty) {
            return Scaffold(
              body: Center(
                child: customText(
                  text: 'Invalid reset token',
                  size: 18,
                  color: Colors.black87,
                ),
              ),
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
        path: '/doctor_dashboard',
        builder: (context, state) => DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/volunteer_survey',
        builder: (context, state) => VolunteerPatientsScreen(),
      ),
    ],
  );
}
