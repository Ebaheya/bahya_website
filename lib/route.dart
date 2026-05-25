import 'package:bahya_app/screens/admin/add_category.dart';
import 'package:bahya_app/screens/admin/add_service.dart';
import 'package:bahya_app/screens/admin/admin_home.dart';
import 'package:bahya_app/screens/admin/all_service.dart';
import 'package:bahya_app/screens/admin/patient_requests_details.dart';
import 'package:bahya_app/screens/admin/patients_search.dart';
import 'package:bahya_app/screens/patients/artical_screen.dart';
import 'package:bahya_app/screens/patients/patients_home.dart';
import 'package:bahya_app/screens/patients/programs_screen.dart';
import 'package:bahya_app/screens/patients/questionnair_screen.dart';
import 'package:bahya_app/screens/patients/requested_service.dart';
import 'package:bahya_app/screens/patients/support_screen.dart';
import 'package:bahya_app/screens/patients/travel_screen.dart';
import 'package:flutter/material.dart';

class AppRoute {
  AppRoute();
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
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
        return MaterialPageRoute(builder: (_) => const QuestionnaireScreen());
      case '/create_category':
        return MaterialPageRoute(builder: (_) => CreateCategoryScreen());
      default:
        return MaterialPageRoute(builder: (_) => CreateCategoryScreen());
    }
  }
}
