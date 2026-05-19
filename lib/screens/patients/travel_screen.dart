import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    return Scaffold(
extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: customAppBar(
        context: context,
        title: 'الرحلات والنزهات',
        subTitle: 'اختاري ما يناسبك وانضمي الآن',
        icon: Icons.directions_bus_rounded,
        isHome: false,
      ),
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
               SizedBox(height: h * 0.15),
              serviceInfo(
                w: getScreenWidth(context),
                h: getScreenHeight(context),
                title: 'رحلة إلى المتحف المصري',
                date: 'الجمعة 15 سبتمبر 2024',
                time: '10:00 صباحًا - 4:00 مساءً',
                location: 'المتحف المصري، القاهرة',
                meetingPlace: 'محطة مترو الأوبرا',
                availableSeats: 10,
                isTravel: true,
              ),
              serviceInfo(
                w: getScreenWidth(context),
                h: getScreenHeight(context),
                title: 'نزهة في حديقة الأزهر',
                date: 'الأحد 20 سبتمبر 2024',
                time: '3:00 مساءً - 6:00 مساءً',
                location: 'حديقة الأزهر، القاهرة',
                meetingPlace: 'محطة مترو الأزهر',
                availableSeats: 15,
                isTravel: true,
              ),
             const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
