import 'package:bahya_website/bloc/cubit/publish_schedule_cubit.dart';
import 'package:bahya_website/bloc/states/publish_schedule_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/schedule/schedule_form.dart';
import 'package:bahya_website/helper/widgets/schedule/scheduled_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PublishScheduleScreen extends StatelessWidget {
  const PublishScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return BlocProvider(
      create: (_) => PublishScheduleCubit(AppRepository())..loadForms(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: customAppBar(
          context: context,
          title: "جدولة النماذج",
          isHomeBar: false,
        ),
        body: BlocConsumer<PublishScheduleCubit, PublishScheduleState>(
          listener: (context, state) {
            if (state.error != null) {
              customDialog(
                context: context,
                title: "خطأ",
                message: state.error!,
                isError: true,
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: customLoading());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<PublishScheduleCubit>().loadForms();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(
                    context,
                    isMobile ? 0.012 : 0.02,
                    min: 12,
                    max: 28,
                  ),
                  vertical: responsiveHeight(context, 0.02, min: 14, max: 28),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 1250,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.025,
                            min: 16,
                            max: 32,
                          ),
                        ),

                        ScheduleFormWidget(forms: state.activeForms),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.04,
                            min: 24,
                            max: 42,
                          ),
                        ),

                        ScheduledListWidget(
                          scheduled: const [],
                          publishedForms: state.publishedForms,
                          publishedAssignments: state.publishedAssignments,
                          isLoadingAssignments: state.isLoadingAssignments,
                        ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.04,
                            min: 24,
                            max: 42,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
