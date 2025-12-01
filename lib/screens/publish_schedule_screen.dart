import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/widgets/schedule_form_widget.dart';
import 'package:bahya_website/helper/widgets/scheduled_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:bahya_website/helper/strings.dart';

class PublishScheduleScreen extends StatelessWidget {
  const PublishScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: "جدولة النماذج",
        isHomeBar: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: h * 0.01),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: h * 0.04),
                ScheduleFormWidget(),
                SizedBox(height: h * 0.04),
                ScheduledListWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
