import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/articles.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
import 'package:bahya_app/helper/widgets/patient_home_widgets.dart';
import 'package:flutter/material.dart';

class PatientsHome extends StatefulWidget {
  const PatientsHome({super.key});

  @override
  State<PatientsHome> createState() => _PatientsHomeState();
}

class _PatientsHomeState extends State<PatientsHome> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: h * 0.15),
                chatBotCard(w: w, h: h),

                const SizedBox(height: 20),

                sectionTitle(w: w, title: "الخدمات المجتمعية"),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: serviceCard(
                        title: "مجموعات الدعم",
                        description: "شاركي تجاربك مع من يفهمونك",
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: serviceCard(
                        title: "الرحلات و التنزهات",
                        description: "استمتعي مع المحاربات في رحلات مميزة",
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: serviceCard(
                        title: "البرامج التعليمية",
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
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                sectionTitle(w: w, title: "مقالات مفيدة"),

                const SizedBox(height: 14),
                articles(w: w, context: context),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: w * 0.4, bottom: 15),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 50),
              navButton(
                w: w,
                h: h,
                title: "طلباتي",
                isSelected: currentIndex == 1,
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                  Navigator.pushNamed(context, '/requestedService');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
