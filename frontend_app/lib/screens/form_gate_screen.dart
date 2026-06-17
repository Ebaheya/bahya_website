import 'package:bahya_app/data/remote/repo/repo.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/patient_forms_cubit.dart';
import 'package:bahya_app/logic/state/patient_forms_state.dart';
import 'package:bahya_app/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormGateScreen extends StatelessWidget {
  const FormGateScreen({super.key});

  void _goTo(BuildContext context, String routeName, {Object? arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        routeName,
        (route) => false,
        arguments: arguments,
      );
    });
  }

  void _showErrorDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr(
          'تعذر تحميل النموذج حالياً. سيتم فتح الصفحة الرئيسية.',
        ),
        isError: true,
        onClose: () {
          navigatorKey.currentState?.pop();
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/patientsHome',
            (route) => false,
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!authNotifier.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      });

      return Scaffold(
        backgroundColor: const Color(0xFFFFF6FC),
        body: Center(child: customLoading()),
      );
    }

    return BlocProvider(
      create: (_) => PatientFormsCubit(AppRepository())..loadMyAssignments(),
      child: BlocConsumer<PatientFormsCubit, PatientFormsState>(
        listenWhen: (previous, current) {
          return previous.hasLoaded != current.hasLoaded ||
              previous.error != current.error ||
              previous.assignments != current.assignments;
        },
        listener: (context, state) {
          if (!state.hasLoaded || state.isLoading) return;

          if (state.error != null) {
            _showErrorDialog(context);
            return;
          }

          if (state.assignments.isNotEmpty) {
            _goTo(
              context,
              '/questionnaire_screen',
              arguments: state.assignments.first.id,
            );
            return;
          }

          _goTo(context, '/patientsHome');
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
