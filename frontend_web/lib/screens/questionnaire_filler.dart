import 'package:bahya_website/bloc/cubit/doctor_cubit.dart';
import 'package:bahya_website/bloc/states/doctor_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/filler/saved_filler.dart';
import 'package:bahya_website/helper/widgets/filler/saved_filler_widget.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
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
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 700;
    final isTablet = w >= 700 && w < 1100;

    final pagePadding = responsiveSize(context, 0.025, min: 8, max: 24);
    final containerPadding = responsiveSize(context, 0.03, min: 10, max: 30);
    final gap = responsiveSize(context, 0.025, min: 10, max: 30);
    final radius = responsiveSize(context, 0.025, min: 16, max: 24);

    final savedFormsHeight = responsiveHeight(
      context,
      0.50,
      min: 380,
      max: 620,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFCEFFE),
      appBar: customAppBar(
        context: context,
        title: 'Fill out questionnaires',
        isHomeBar: false,
      ),
      body: SafeArea(
        child: BlocConsumer<DoctorFormsCubit, DoctorFormsState>(
          listenWhen: (previous, current) {
            return previous.error != current.error ||
                previous.createdAssessment != current.createdAssessment;
          },
          listener: (context, state) {
            if (state.error != null) {
              customSnackBar(context: context, message: state.error!);
            }

            if (state.createdAssessment != null) {
              final score = state.createdAssessment?["score"] ?? 0;
              final diagnosis =
                  state.createdAssessment?["diagnosis"] ??
                  localizedText(context, 'Not specified');
              final patientStatus =
                  state.createdAssessment?["patientStatus"] ??
                  localizedText(context, 'Not specified');
              final diagnosisLabel = localizedText(context, 'Diagnosis');
              final scoreLabel = localizedText(context, 'Score');
              final statusLabel = localizedText(context, 'Patient status');

              customDialog(
                context: context,
                title: 'Assessment saved successfully',
                message:
                    '$diagnosisLabel: $diagnosis\n$scoreLabel: $score\n$statusLabel: $patientStatus',
                isError: false,
              );

              context.read<DoctorFormsCubit>().clearCreatedAssessment();
            }
          },
          builder: (context, state) {
            if (state.isLoadingForms) {
              return Center(child: customLoading());
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: SizedBox(
                    width: isMobile ? w : w * 0.95,
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: EdgeInsets.all(pagePadding),
                      child: isMobile
                          ? Column(
                              children: [
                                SizedBox(
                                  height: savedFormsHeight,
                                  child: SavedFormsWidget(
                                    forms: state.forms,
                                    selectedFormId:
                                        state.selectedForm?.id ?? "",
                                    isMobileLayout: true,
                                    onSelect: (id) {
                                      context
                                          .read<DoctorFormsCubit>()
                                          .selectForm(id);
                                    },
                                  ),
                                ),
                                SizedBox(height: gap),
                                Expanded(
                                  child: _formContainer(
                                    context: context,
                                    padding: containerPadding,
                                    radius: radius,
                                    child: state.isLoadingFormDetails
                                        ? Center(child: customLoading())
                                        : DynamicFormFillerWidget(
                                            form: state.selectedForm,
                                            patients: state.patientOptions,
                                            selectedPatient:
                                                state.selectedPatient,
                                            isSearchingPatients:
                                                state.isSearchingPatients,
                                            isSubmitting:
                                                state.isSubmittingAssessment,
                                          ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: isTablet ? 2 : 3,
                                  child: _formContainer(
                                    context: context,
                                    padding: containerPadding,
                                    radius: radius,
                                    child: state.isLoadingFormDetails
                                        ? Center(child: customLoading())
                                        : DynamicFormFillerWidget(
                                            form: state.selectedForm,
                                            patients: state.patientOptions,
                                            selectedPatient:
                                                state.selectedPatient,
                                            isSearchingPatients:
                                                state.isSearchingPatients,
                                            isSubmitting:
                                                state.isSubmittingAssessment,
                                          ),
                                  ),
                                ),
                                SizedBox(width: gap),
                                SizedBox(
                                  width: isTablet ? w * 0.32 : w * 0.23,
                                  height: h,
                                  child: SavedFormsWidget(
                                    forms: state.forms,
                                    selectedFormId:
                                        state.selectedForm?.id ?? "",
                                    isMobileLayout: false,
                                    onSelect: (id) {
                                      context
                                          .read<DoctorFormsCubit>()
                                          .selectForm(id);
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _formContainer({
    required BuildContext context,
    required Widget child,
    required double padding,
    required double radius,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}
