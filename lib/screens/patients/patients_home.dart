import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:flutter/material.dart';

class PatientsHome extends StatelessWidget {
  const PatientsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    return Scaffold(
      appBar: customAppBar(
        title: "أهلاً بعودتك، البطلة",
        subTitle: 'اليوم هو بداية جديدة مليئة بالأمل',
        context: context,
      ),
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              chatBotCard(w: w, h: h),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: customText(
                  text: "الخدمات المجتمعية",
                  size: w * 0.05,
                  isCenter: false,
                ),
              ),
              SizedBox(height: 20),
              serviceCard(
                title: "البرامج التعليميه",
                description: "انضمي إلى برامجنا التعليمية",
                onTap: () {
                  Navigator.pushNamed(context, '/programsScreen');
                },
                w: w,
                h: h,
                icon: Icons.menu_book_rounded,
                primaryColor: Colors.green[100]!,
                secondaryColor: Colors.green[400]!,
                buttonColor: Colors.green,
                salesBackgroundColor: Colors.green[300]!,
              ),
              SizedBox(height: 20),
              serviceCard(
                title: "الرحلات و النزهات",
                description: "استمتعى مع المحاربات",
                onTap: () {
                  Navigator.pushNamed(context, '/travelScreen');
                },
                w: w,
                h: h,
                icon: Icons.directions_bus_rounded,
                primaryColor: Colors.blue[100]!,
                secondaryColor: Colors.blue[400]!,
                buttonColor: Colors.blue,
                salesBackgroundColor: Colors.blue[300]!,
              ),
              SizedBox(height: 20),
              serviceCard(
                title: "مجموعات الدعم",
                description: "شاركى تجاربيك مع من يفهومنك",
                onTap: () {
                  Navigator.pushNamed(context, '/supportScreen');
                },
                w: w,
                h: h,
                icon: Icons.groups_rounded,
                primaryColor: Colors.purple[100]!,
                secondaryColor: Colors.purple[400]!,
                buttonColor: Colors.purple,
                salesBackgroundColor: Colors.purple[300]!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
