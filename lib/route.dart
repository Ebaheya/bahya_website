import 'dart:convert';

import 'package:bahya_app/data/local/data_secure.dart';
import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/patient_forms_cubit.dart';
import 'package:bahya_app/logic/cubit/service_admin_cubit.dart';
import 'package:bahya_app/screens/admin/add_category.dart';
import 'package:bahya_app/screens/admin/add_service.dart';
import 'package:bahya_app/screens/admin/admin_home.dart';
import 'package:bahya_app/screens/admin/all_service.dart';
import 'package:bahya_app/screens/admin/patient_requests_details.dart';
import 'package:bahya_app/screens/admin/patients_search.dart';
import 'package:bahya_app/screens/login.dart';
import 'package:bahya_app/screens/patients/artical_screen.dart';
import 'package:bahya_app/screens/form_gate_screen.dart';
import 'package:bahya_app/screens/patients/chatbot_screen.dart';
import 'package:bahya_app/screens/patients/patients_home.dart';
import 'package:bahya_app/screens/patients/services_screen.dart';
import 'package:bahya_app/screens/patients/questionnair_screen.dart';
import 'package:bahya_app/screens/patients/requested_service.dart';
import 'package:bahya_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _userRole;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get userRole => _userRole;
  bool get isAdmin => _userRole == 'ADMIN';
  bool get isPatient => _userRole == 'PATIENT';

  String get homeRoute {
    if (isAdmin) return '/adminHome';
    if (isPatient) return '/formGate';
    return '/unauthorized';
  }

  Future<void> checkLogin() async {
    _isLoading = true;
    notifyListeners();

    final storage = SecureStorageService();

    final accessToken = await storage.getAccessToken();
    final refreshToken = await storage.getRefreshToken();
    final storedRole = await storage.getUserRole();

    _isLoggedIn =
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;

    if (_isLoggedIn) {
      final jwtRole = _roleFromJwt(accessToken);
      final fallbackRole = storedRole?.toUpperCase();

      _userRole = jwtRole ?? fallbackRole;

      if (_userRole != null && _userRole!.isNotEmpty) {
        await storage.saveUserRole(_userRole!);
      }
    } else {
      _userRole = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void login({String? role}) {
    _isLoggedIn = true;
    _userRole = role;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final storage = SecureStorageService();
    await storage.clearTokens();

    _isLoggedIn = false;
    _userRole = null;
    _isLoading = false;
    notifyListeners();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Future<void> forceLogout() async {
    final storage = SecureStorageService();
    await storage.clearTokens();

    _isLoggedIn = false;
    _userRole = null;
    _isLoading = false;
    notifyListeners();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  String? _roleFromJwt(String? token) {
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);

      if (json is Map<String, dynamic>) {
        final role = json['role']?.toString().toUpperCase();
        return role?.isEmpty == true ? null : role;
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}

final AuthNotifier authNotifier = AuthNotifier();

class AppRoute {
  AppRoute();

  static const List<String> publicRoutes = [
    '/',
    '/splash',
    '/login',
    '/loading',
  ];

  Route generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';

    if (routeName == '/' || routeName == '/splash') {
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    }

    if (authNotifier.isLoading && routeName != '/loading') {
      return MaterialPageRoute(builder: (_) => const LoadingScreen());
    }

    if (!authNotifier.isLoggedIn && !publicRoutes.contains(routeName)) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }

    if (authNotifier.isLoggedIn && routeName == '/login') {
      return MaterialPageRoute(builder: (_) => _screenForHomeRoute());
    }

    switch (routeName) {
      case '/loading':
        return MaterialPageRoute(builder: (_) => const LoadingScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/unauthorized':
        return MaterialPageRoute(builder: (_) => const UnauthorizedScreen());

      case '/patientsHome':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                ServiceAdminCubit(AppRepository())..loadPatientHomeData(),
            child: const PatientsHome(),
          ),
        );

      case '/servicesScreen':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ServicesScreen(),
        );

      case '/requestedService':
        return MaterialPageRoute(builder: (_) => const RequestedService());

      case '/adminHome':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ServiceAdminCubit(AppRepository())..loadDashboard(),
            child: AdminHome(),
          ),
        );

      case '/addService':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ServiceAdminCubit(AppRepository())..loadDashboard(),
            child: const AddService(),
          ),
        );

      case '/patientsSearch':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                ServiceAdminCubit(AppRepository())
                  ..loadPatientRequestsDetails(),
            child: const PatientsSearch(),
          ),
        );
      case '/addCategory':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ServiceAdminCubit(AppRepository())..loadDashboard(),
            child: const CreateCategoryScreen(),
          ),
        );

      case '/chatbotScreen':
        return MaterialPageRoute(builder: (_) => const ChatBotScreen());

      case '/patientRequestsDetails':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => ServiceAdminCubit(AppRepository()),
            child: const PatientRequestsDetails(),
          ),
        );

      case '/articleDetails':
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => ArticleDetailsScreen(
            title: args['title'],
            introduction: args['introduction'],
            firstQuestion: args['firstQuestion'],
            firstAnswer: args['firstAnswer'],
            secondQuestion: args['secondQuestion'],
            secondAnswer: args['secondAnswer'],
            thirdQuestion: args['thirdQuestion'],
            thirdAnswer: args['thirdAnswer'],
            fourthQuestion: args['fourthQuestion'],
            fourthAnswer: args['fourthAnswer'],
            conclusion: args['conclusion'],
          ),
        );

      case '/all_services':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ServiceAdminCubit(AppRepository())..loadDashboard(),
            child: const AllServicesScreen(),
          ),
        );

      case '/questionnaire_screen':
        final assignmentId = settings.arguments as String?;

        if (assignmentId == null || assignmentId.isEmpty) {
          return MaterialPageRoute(builder: (_) => const FormGateScreen());
        }

        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => PatientFormsCubit(AppRepository()),
            child: QuestionnaireScreen(assignmentId: assignmentId),
          ),
        );

      case '/create_category':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ServiceAdminCubit(AppRepository())..loadDashboard(),
            child: const CreateCategoryScreen(),
          ),
        );

      case '/formGate':
        if (!authNotifier.isPatient) {
          return MaterialPageRoute(builder: (_) => _screenForHomeRoute());
        }

        return MaterialPageRoute(builder: (_) => const FormGateScreen());

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }

  Widget _screenForHomeRoute() {
    switch (authNotifier.homeRoute) {
      case '/adminHome':
        return BlocProvider(
          create: (_) => ServiceAdminCubit(AppRepository())..loadDashboard(),
          child: AdminHome(),
        );
      case '/formGate':
        return const FormGateScreen();
      default:
        return const UnauthorizedScreen();
    }
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: customLoading()));
  }
}

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Color(0xFFE7549B),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('غير مصرح لك.'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontFamily: 'ArabicCustomFont',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('هذا الحساب غير مصرح له باستخدام هذا التطبيق.'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'ArabicCustomFont',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => authNotifier.logout(),
                child: Text(context.tr('تسجيل الخروج')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
