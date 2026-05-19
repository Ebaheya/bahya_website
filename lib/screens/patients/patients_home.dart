import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
import 'package:bahya_app/helper/widgets/custom_app_bar.dart';
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
                chatBotCard(w: w, h: h),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.pink[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    customText(
                      text: "الخدمات المجتمعية",
                      size: w * 0.05,
                      isCenter: false,
                    ),
                  ],
                ),

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

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: w * 0.5, bottom: 15),
        child: Container(
          height: 75,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 50),
              navButton(
                w: w,
                title: "طلباتي",
                isSelected: currentIndex == 1,
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                    Navigator.pushNamed(context, '/requestedService');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required double w,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.pink[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.pink[300]!.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: customText(text: 'طلباتى', size: w * 0.04, color: textColor),
      ),
    );
  }
}
