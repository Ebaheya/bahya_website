import 'package:bahya_app/screens/patients/patients_home.dart';
import 'package:flutter/material.dart';

class AppRoute {
  AppRoute();
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/patientsHome':
        return MaterialPageRoute(builder: (_) => const PatientsHome());
      default:
        return MaterialPageRoute(builder: (_) => PatientsHome());
    }
  }
}
