import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/constant.dart';
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

                articleCard(
                  w: w,
                  icon: Icons.favorite_rounded,
                  topic: "استدعاء الكشف مع طبيب نفسي",
                  subTopic:
                      "في بعض الحالات النفسية لا يكون العلاج النفسي وحده كافيًا",
                  color: Colors.pink,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/articleDetails',
                      arguments: {
                        'title': "نصائح للتعامل مع القلق أثناء العلاج",
                        'introduction':
                            'في بعض الحالات النفسية لا يكون العلاج النفسي وحده كافيًا، وتظهر الحاجة إلى تدخل طبي دوائي تحت إشراف طبيب نفسي، خاصة عندما تكون الأعراض شديدة أو معقدة أو مؤثرة على الحياة اليومية.',
                        'firstQuestion':
                            'ما الفرق بين المعالج النفسي والطبيب النفسي؟',
                        'firstAnswer':
                            'المعالج النفسي يركز على الجلسات والتدخلات السلوكية والمعرفية وتنمية المهارات. أما الطبيب النفسي فهو طبيب مختص بتشخيص الاضطرابات النفسية ووصف الأدوية ومتابعة تأثيرها وتعديل الجرعات عند الحاجة.',
                        'secondQuestion':
                            'ما الأعراض التي تستدعي الكشف مع طبيب نفسي؟',
                        'secondAnswer':
                            'من أهم الأعراض: الهلاوس، الضلالات، التقلبات المزاجية الحادة، نوبات الهوس، الاكتئاب الشديد المصحوب بأفكار انتحارية، فقدان القدرة على أداء الوظائف اليومية، أو السلوك العدواني والاندفاعي غير المسيطر عليه.',
                        'thirdQuestion':
                            'ما الاضطرابات التي تحتاج غالبًا إلى علاج دوائي؟',
                        'thirdAnswer':
                            'تشمل الاضطرابات الذهانية مثل الفصام، والاضطراب الوجداني ثنائي القطب، والاكتئاب الشديد أو المقاوم للعلاج، والوسواس القهري الشديد، واضطرابات تعاطي المواد.',
                        'fourthQuestion':
                            'متى يكون التحويل للطبيب النفسي عاجلًا؟',
                        'fourthAnswer':
                            'يصبح التحويل عاجلًا عند ظهور أعراض ذهانية لأول مرة، أو حدوث نوبة هوس حادة، أو وجود أفكار انتحارية بخطة واضحة، أو تدهور سريع في السلوك أو الإدراك.',
                        'conclusion':
                            'الكشف مع طبيب نفسي لا يعني فشل العلاج النفسي، بل هو خطوة ضرورية في الحالات التي تحتاج إلى تدخل طبي متخصص. التعاون بين المعالج والطبيب يساعد على تحقيق أمان أكبر وتحسن مستقر على المدى الطويل.',
                      },
                    );
                  },
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
}
