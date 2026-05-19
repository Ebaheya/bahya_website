import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class RequestedService extends StatelessWidget {
  const RequestedService({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: customAppBar(
        context: context,
        title: 'طلباتي',
        subTitle: 'هنا يمكنك متابعة طلباتك الحالية',
        isHome: false,
        
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                 SizedBox(height: h * 0.15),
                requestedState(w: w, h: h),
                serviceInfo(
                  isCompleted: true,
                  isRequested: true,
                  w: w,
                  h: h,
                  title: 'دروس محو الأمية - المستوى الأول',
                  date: 'السبت والاثنين والأربعاء',
                  time: '5:00 مساءً - 6:30 مساءً',
                  location: 'بهيه - الشيخ زايد',
                ),
                serviceInfo(
                  isSupport: true,
                  isRequested: true,
                  isUnderReview: true,
                  w: w,
                  h: h,
                  title: 'دروس محو الأمية - المستوى الأول',
                  date: 'السبت والاثنين والأربعاء',
                  time: '5:00 مساءً - 6:30 مساءً',
                  location: 'بهيه - الشيخ زايد',
                ),
                serviceInfo(
                  isRequested: true,
                  isTravel: true,
                  w: w,
                  h: h,
                  title: 'دروس محو الأمية - المستوى الأول',
                  date: 'السبت والاثنين والأربعاء',
                  time: '5:00 مساءً - 6:30 مساءً',
                  location: 'بهيه - الشيخ زايد',
                  meetingPlace: 'محطة مترو الشيخ زايد',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
