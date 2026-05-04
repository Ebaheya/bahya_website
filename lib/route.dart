import 'package:bahya_website/screens/admin_panel/admin_panal.dart';
import 'package:go_router/go_router.dart';

import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/patient_info.dart';
import 'screens/add_questionnaire.dart';
import 'screens/publish_schedule_screen.dart';
import 'screens/questionnaire_filler.dart';
import 'screens/volunteer_survey_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/admin',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
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
