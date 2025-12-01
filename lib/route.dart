import 'package:bahya_website/screens/add_questionnaire.dart';
import 'package:bahya_website/screens/home.dart';
import 'package:bahya_website/screens/login.dart';
import 'package:bahya_website/screens/patient_info.dart';
import 'package:bahya_website/screens/publish_schedule_screen.dart';
import 'package:bahya_website/screens/questionnaire_filler.dart';
import 'package:flutter/material.dart';

class AppRoute {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/patient_info':
        return MaterialPageRoute(builder: (_) => PatientInfo());
      case '/add_questionnaire':
        return MaterialPageRoute(builder: (_) =>  AddQuestionnaire());
      case '/publish_schedule':
        return MaterialPageRoute(builder: (_) =>  PublishScheduleScreen());
      case '/questionnaire_filler':
        return MaterialPageRoute(builder: (_) =>  FormsScreen());
      default:
        return MaterialPageRoute(builder: (_) => LoginPage());
    }
  }
}
