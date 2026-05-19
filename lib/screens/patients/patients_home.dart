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

                articleCard(
                  w: w,
                  icon: Icons.favorite_rounded,
                  topic: "نصائح للتعامل مع القلق أثناء العلاج",
                  subTopic: "خطوات بسيطة تساعدك على الهدوء والدعم النفسي",
                  color: Colors.pink,
                  onTap: () {},
                ),

                const SizedBox(height: 12),

                articleCard(
                  w: w,
                  icon: Icons.restaurant_rounded,
                  topic: "أهمية التغذية الصحية",
                  subTopic: "أكلات مفيدة تساعد جسمك خلال رحلة العلاج",
                  color: Colors.green,
                  onTap: () {},
                ),

                const SizedBox(height: 12),

                articleCard(
                  w: w,
                  icon: Icons.medical_services_rounded,
                  topic: "متى أحتاج للتواصل مع الطبيب؟",
                  subTopic: "علامات مهمة لا يجب تجاهلها أثناء المتابعة",
                  color: Colors.blue,
                  onTap: () {},
                ),

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

  Widget sectionTitle({required double w, required String title}) {
    return Row(
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
        customText(text: title, size: w * 0.05, isCenter: false),
      ],
    );
  }

  Widget articleCard({
    required double w,
    required IconData icon,
    required String topic,
    required String subTopic,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: w * 0.14,
              width: w * 0.14,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: w * 0.07),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: topic,
                    size: w * 0.035,
                    bold: true,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  customText(
                    text: subTopic,
                    size: w * 0.028,
                    color: Colors.grey,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: w * 0.045,
            ),
          ],
        ),
      ),
    );
  }

  Widget navButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required double w,
    required double h,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w * 0.45,
        height: h * 0.06,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.pink[100]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.pink[200]!.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.pink[300],
              size: w * 0.05,
            ),
            SizedBox(width: 8),
            Expanded(
              child: customText(
                text: title,
                size: w * 0.045,
                color: textColor,
                bold: true,
              ),
            ),
            Container(
              width: 1.5,
              height: 30,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.pink[100],
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
