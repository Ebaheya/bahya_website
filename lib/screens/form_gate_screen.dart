import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/logic/cubit/patient_forms_cubit.dart';
import 'package:bahya_app/logic/state/patient_forms_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormGateScreen extends StatelessWidget {
  const FormGateScreen({super.key});

  void _goTo(BuildContext context, String routeName, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.white,
            title: const Text(
              'حدث خطأ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8A2BE2),
              ),
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF333333),
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _goTo(context, '/patientsHome');
                },
                child: const Text('حسنًا'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientFormsCubit(AppRepository())..loadMyAssignments(),
      child: BlocConsumer<PatientFormsCubit, PatientFormsState>(
        listenWhen: (previous, current) {
          return previous.isLoading != current.isLoading ||
              previous.error != current.error ||
              previous.assignments != current.assignments;
        },
        listener: (context, state) {
          if (state.isLoading) return;

          if (state.error != null) {
            _showErrorDialog(
              context,
              state.error ?? 'حدث خطأ أثناء تحميل النماذج.',
            );
            return;
          }

          if (state.assignments.isNotEmpty) {
            _goTo(
              context,
              '/questionnaire_screen',
              arguments: state.assignments.first.id,
            );
          } else {
            _goTo(context, '/patientsHome');
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
