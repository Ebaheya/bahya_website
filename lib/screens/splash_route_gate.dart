import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/logic/cubit/patient_forms_cubit.dart';
import 'package:bahya_app/route.dart';
import 'package:bahya_app/services/internet_connection_service.dart';
import 'package:flutter/material.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    final hasInternet = await InternetConnectionService.instance.hasInternet();

    if (!mounted) return;

    if (!hasInternet) {
      _goTo('/noInternet');
      return;
    }

    await authNotifier.checkLogin();

    if (!mounted) return;

    if (!authNotifier.isLoggedIn) {
      _goTo('/login');
      return;
    }

    if (authNotifier.isAdmin) {
      _goTo('/adminHome');
      return;
    }

    if (authNotifier.isDoctor) {
      _goTo('/doctorHome');
      return;
    }

    if (authNotifier.isPatient) {
      await _handlePatientGate();
      return;
    }

    _goTo('/unauthorized');
  }

  Future<void> _handlePatientGate() async {
    final cubit = PatientFormsCubit(AppRepository());

    try {
      await cubit.loadMyAssignments();

      if (!mounted) return;

      final state = cubit.state;

      if (state.error != null || state.assignments.isEmpty) {
        _goTo('/patientsHome');
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/questionnaire_screen',
        (route) => false,
        arguments: state.assignments.first.id,
      );
    } catch (_) {
      if (!mounted) return;
      _goTo('/patientsHome');
    } finally {
      await cubit.close();
    }
  }

  void _goTo(String routeName) {
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: customLoading()),
    );
  }
}
