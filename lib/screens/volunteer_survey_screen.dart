import 'package:bahya_website/bloc/cubit/volunteer_cubit.dart';
import 'package:bahya_website/bloc/states/volunteer_assignments_state.dart';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/volunteer/patients_list.dart';
import 'package:bahya_website/helper/widgets/volunteer/volunteer_patients_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VolunteerPatientsScreen extends StatelessWidget {
  const VolunteerPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VolunteerAssignmentsCubit(WebService())..loadAssignments(),
      child: const _VolunteerPatientsView(),
    );
  }
}

class _VolunteerPatientsView extends StatelessWidget {
  const _VolunteerPatientsView();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final isMobile = w < 700;
    final isTablet = w >= 700 && w < 1100;

    final pagePadding = responsiveSize(
      context,
      isMobile ? 0.018 : 0.025,
      min: isMobile ? 8 : 10,
      max: isMobile ? 14 : 24,
    );

    final gap = responsiveSize(
      context,
      isMobile ? 0.018 : 0.024,
      min: isMobile ? 10 : 12,
      max: isMobile ? 16 : 30,
    );

    final formPadding = responsiveSize(
      context,
      isMobile ? 0.018 : 0.03,
      min: isMobile ? 10 : 14,
      max: isMobile ? 16 : 30,
    );

    final radius = responsiveSize(
      context,
      isMobile ? 0.045 : 0.026,
      min: isMobile ? 18 : 18,
      max: isMobile ? 22 : 26,
    );

    final patientsHeight = responsiveHeight(
      context,
      isMobile ? 0.34 : 0.70,
      min: isMobile ? 400 : 500,
      max: isMobile ? 600 : h,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFCEFFE),
      appBar: customAppBar(
        context: context,
        title: "ملء استبيانات المرضى",
        isHomeBar: false,
      ),
      body: SafeArea(
        child:
            BlocConsumer<VolunteerAssignmentsCubit, VolunteerAssignmentsState>(
              listener: (context, state) {
                if (state.error != null) {
                  customDialog(
                    context: context,
                    title: 'تنبيه',
                    message: state.error!,
                    isError: true,
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading && !state.hasLoaded) {
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
                                      height: patientsHeight,
                                      child: PatientsListWidget(
                                        assignments: state.assignments,
                                        selectedAssignmentId: state
                                            .selectedAssignment?['id']
                                            ?.toString(),
                                        onSelect: (assignment) {
                                          context
                                              .read<VolunteerAssignmentsCubit>()
                                              .selectAssignment(assignment);
                                        },
                                      ),
                                    ),
                                    SizedBox(height: gap),
                                    Expanded(
                                      child: _formContainer(
                                        context: context,
                                        state: state,
                                        padding: formPadding,
                                        radius: radius,
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
                                        state: state,
                                        padding: formPadding,
                                        radius: radius,
                                      ),
                                    ),
                                    SizedBox(width: gap),
                                    SizedBox(
                                      width: isTablet ? w * 0.32 : w * 0.24,
                                      height: constraints.maxHeight,
                                      child: PatientsListWidget(
                                        assignments: state.assignments,
                                        selectedAssignmentId: state
                                            .selectedAssignment?['id']
                                            ?.toString(),
                                        onSelect: (assignment) {
                                          context
                                              .read<VolunteerAssignmentsCubit>()
                                              .selectAssignment(assignment);
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
    required VolunteerAssignmentsState state,
    required double padding,
    required double radius,
  }) {
    if (state.assignments.isEmpty) {
      return _emptyCard(
        text: 'لا توجد استبيانات مسندة لك حالياً.',
        padding: padding,
        radius: radius,
      );
    }

    if (state.isLoadingDetails) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: _cardDecoration(radius),
        child: Center(child: customLoading()),
      );
    }

    if (state.selectedAssignmentDetails == null) {
      return _emptyCard(
        text: 'اختاري مريض من القائمة لعرض الاستبيان.',
        padding: padding,
        radius: radius,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: _cardDecoration(radius),
      child: VolunteerSurveyWidget(
        assignmentDetails: state.selectedAssignmentDetails!,
        onSave: () async {
          final success = await context
              .read<VolunteerAssignmentsCubit>()
              .submitSelectedAssignment();

          if (!context.mounted) return;

          if (success) {
            customDialog(
              context: context,
              title: "تم الحفظ",
              message: "تم تسجيل الاستبيان بنجاح.",
              isSuccess: true,
            );
          }
        },
      ),
    );
  }

  BoxDecoration _cardDecoration(double radius) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7A004C).withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _emptyCard({
    required String text,
    required double padding,
    required double radius,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: _cardDecoration(radius),
      child: Center(
        child: customText(text: text, size: 18, color: Colors.grey, bold: true),
      ),
    );
  }
}
