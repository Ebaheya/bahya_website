import 'package:bahya_app/data/local/data_secure.dart';
import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/logic/cubit/patient_forms_cubit.dart';
import 'package:bahya_app/screens/admin/add_category.dart';
import 'package:bahya_app/screens/admin/add_service.dart';
import 'package:bahya_app/screens/admin/admin_home.dart';
import 'package:bahya_app/screens/admin/all_service.dart';
import 'package:bahya_app/screens/admin/patient_requests_details.dart';
import 'package:bahya_app/screens/admin/patients_search.dart';
import 'package:bahya_app/screens/login.dart';
import 'package:bahya_app/screens/patients/artical_screen.dart';
import 'package:bahya_app/screens/form_gate_screen.dart';
import 'package:bahya_app/screens/patients/patients_home.dart';
import 'package:bahya_app/screens/patients/programs_screen.dart';
import 'package:bahya_app/screens/patients/questionnair_screen.dart';
import 'package:bahya_app/screens/patients/requested_service.dart';
import 'package:bahya_app/screens/patients/support_screen.dart';
import 'package:bahya_app/screens/patients/travel_screen.dart';
import 'package:bahya_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

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

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  Future<void> forceLogout() async {
    final storage = SecureStorageService();
    await storage.clearTokens();

    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
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
      return MaterialPageRoute(builder: (_) => const PatientsHome());
    }

    switch (routeName) {
      case '/loading':
        return MaterialPageRoute(builder: (_) => const LoadingScreen());

      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/patientsHome':
        return MaterialPageRoute(builder: (_) => const PatientsHome());

      case '/programsScreen':
        return MaterialPageRoute(builder: (_) => const ProgramsScreen());

      case '/travelScreen':
        return MaterialPageRoute(builder: (_) => const TravelScreen());

      case '/supportScreen':
        return MaterialPageRoute(builder: (_) => const SupportScreen());

      case '/requestedService':
        return MaterialPageRoute(builder: (_) => const RequestedService());

      case '/adminHome':
        return MaterialPageRoute(builder: (_) => const AdminHome());

      case '/addService':
        return MaterialPageRoute(builder: (_) => AddService());

      case '/patientsSearch':
        return MaterialPageRoute(builder: (_) => const PatientsSearch());

      case '/patientRequestsDetails':
        return MaterialPageRoute(
          builder: (_) => const PatientRequestsDetails(),
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
        return MaterialPageRoute(builder: (_) => const AllServicesScreen());

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
        return MaterialPageRoute(builder: (_) => CreateCategoryScreen());

      case '/formGate':
        return MaterialPageRoute(builder: (_) => const FormGateScreen());

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
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
