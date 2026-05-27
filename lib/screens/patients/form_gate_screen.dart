import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/logic/cubit/patient_forms_cubit.dart';
import 'package:bahya_app/logic/cubit/patient_forms_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormGateScreen extends StatelessWidget {
  const FormGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientFormsCubit(AppRepository())..loadMyAssignments(),
      child: BlocConsumer<PatientFormsCubit, PatientFormsState>(
        listener: (context, state) {
          if (state.isLoading) return;

          if (state.error != null) {
            Navigator.pushReplacementNamed(context, '/patientsHome');
            return;
          }

          if (state.assignments.isNotEmpty) {
            Navigator.pushReplacementNamed(
              context,
              '/questionnaire_screen',
              arguments: state.assignments.first.id,
            );
          } else {
            Navigator.pushReplacementNamed(context, '/patientsHome');
          }
        },
        builder: (context, state) {
          return Scaffold(
            
            backgroundColor: const Color(0xFFFFF6FC),
            body: Center(child: customLoading()),
          );
        },
      ),
    );
  }
}
