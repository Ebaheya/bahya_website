import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: customAppBar(
        context: context,
        title: 'جلسات الدعم النفسي',
        subTitle: 'اختاري ما يناسبك وانضمي الآن',
        icon: Icons.directions_bus_rounded,
        isHome: false,
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              serviceInfo(
                w: getScreenWidth(context),
                h: getScreenHeight(context),
                title: 'جلسة دعم نفسي جماعية',
                date: 'الجمعة 10 أكتوبر 2024',
                time: '5:00 مساءً - 6:30 مساءً',
                location: 'بهيه - الشيخ زايد',
                availableSeats: 20,
                isSupport: true,
              ),
              serviceInfo(
                w: getScreenWidth(context),
                h: getScreenHeight(context),
                title: 'جلسة دعم نفسي فردية',
                date: 'الأحد 12 أكتوبر 2024',
                time: '3:00 مساءً - 4:00 مساءً',
                location: 'بهيه - الشيخ زايد',
                availableSeats: 10,
                isSupport: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
