import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:flutter/material.dart';

class RequestedService extends StatelessWidget {
  const RequestedService({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: 'طلباتي',
        subTitle: 'هنا يمكنك متابعة طلباتك الحالية',
        isHome: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              requestedState(w: w, h: h),
            ],
          ),
        ),
      ),
    );
  }
}
