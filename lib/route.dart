import 'package:bahya_app/screens/patients/patients_home.dart';
import 'package:bahya_app/screens/patients/programs_screen.dart';
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
      default:
        return MaterialPageRoute(builder: (_) => PatientsHome());
    }
  }
}
