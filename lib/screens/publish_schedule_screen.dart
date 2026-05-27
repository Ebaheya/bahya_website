import 'package:bahya_website/bloc/cubit/publish_schedule_cubit.dart';
import 'package:bahya_website/bloc/states/publish_schedule_state.dart';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/schedule_form.dart';
import 'package:bahya_website/helper/widgets/scheduled_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PublishScheduleScreen extends StatelessWidget {
  const PublishScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return BlocProvider(
      create: (_) => PublishScheduleCubit(AppRepository())..loadForms(),
      child: Scaffold(
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
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: h * 0.01),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: h * 0.04),
                        ScheduleFormWidget(forms: state.draftForms),
                        SizedBox(height: h * 0.04),
                        ScheduledListWidget(
                          scheduled: const [],
                          publishedForms: state.publishedForms,
                           publishedAssignments: state.publishedAssignments,
                          isLoadingAssignments: state.isLoadingAssignments,
                        ),
                        SizedBox(height: h * 0.04),
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
