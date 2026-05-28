import 'package:bahya_website/bloc/cubit/doctor_cubit.dart';
import 'package:bahya_website/bloc/states/doctor_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/widgets/saved_filler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormsScreen extends StatelessWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorFormsCubit(AppRepository())..loadForms(),
      child: const _FormsScreenBody(),
    );
  }
}

class _FormsScreenBody extends StatelessWidget {
  const _FormsScreenBody();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFCEFFE),
      appBar: customAppBar(
        context: context,
        title: "ملء الاستبيانات",
        isHomeBar: false,
      ),
      body: BlocConsumer<DoctorFormsCubit, DoctorFormsState>(
        listenWhen: (previous, current) {
          return previous.error != current.error ||
              previous.createdAssessment != current.createdAssessment;
        },
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }

         if (state.createdAssessment != null) {
            final score = state.createdAssessment?["score"] ?? 0;
            final diagnosis =
                state.createdAssessment?["diagnosis"] ?? "غير محدد";
            final patientStatus =
                state.createdAssessment?["patientStatus"] ?? "غير محدد";

            customDialog(
              context: context,
              title: "تم حفظ التقييم بنجاح",
              message:
                  "التشخيص: $diagnosis\nالاسكور: $score\nحالة المريض: $patientStatus",
              isError: false,
            );

            context.read<DoctorFormsCubit>().clearCreatedAssessment();
          }
        },
        builder: (context, state) {
          if (state.isLoadingForms) {
            return Center(child: customLoading());
          }

          return Center(
            child: Container(
              width: w * 0.95,
              padding: const EdgeInsets.all(20),
              child: isMobile
                  ? Column(
                      children: [
                        SavedFormsWidget(
                          forms: state.forms,
                          selectedFormId: state.selectedForm?.id ?? "",
                          onSelect: (id) {
                            context.read<DoctorFormsCubit>().selectForm(id);
                          },
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _formContainer(
                            child: state.isLoadingFormDetails
                                ? Center(child: customLoading())
                                : DynamicFormFillerWidget(
                                    form: state.selectedForm,
                                    patients: state.patientOptions,
                                    selectedPatient: state.selectedPatient,
                                    isSearchingPatients:
                                        state.isSearchingPatients,
                                    isSubmitting: state.isSubmittingAssessment,
                                  ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _formContainer(
                            child: state.isLoadingFormDetails
                                ? Center(child: customLoading())
                                : DynamicFormFillerWidget(
                                    form: state.selectedForm,
                                    patients: state.patientOptions,
                                    selectedPatient: state.selectedPatient,
                                    isSearchingPatients:
                                        state.isSearchingPatients,
                                    isSubmitting: state.isSubmittingAssessment,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        SavedFormsWidget(
                          forms: state.forms,
                          selectedFormId: state.selectedForm?.id ?? "",
                          onSelect: (id) {
                            context.read<DoctorFormsCubit>().selectForm(id);
                          },
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _formContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: child,
    );
  }
}
