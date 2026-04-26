import 'dart:developer';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/diagnosis_chart.dart';
import 'package:bahya_website/helper/widgets/home_drawer.dart';
import 'package:bahya_website/helper/widgets/home_feature_grid.dart';
import 'package:bahya_website/helper/widgets/state_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

Future<void> loadUser() async {
    try {
      final storage = SecureStorageService();
      final token = await storage.getAccessToken();

      if (token != null) {
        final repo = AppRepository();
        final user = await repo.getUserProfile(accessToken: token);

        setState(() {
          userName = user.name;
        });

        log("name: $userName");
      }
    } catch (e) {
      log("loadUser error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: HomeDrawer(userName: userName),
      appBar: customAppBar(
        context: context,
        title: ' فريق الدعم النفسي',
        isHomeBar: true,
        scaffoldKey: _scaffoldKey,
      ),
      backgroundColor: const Color(0xFFFDF7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getScreenHeight(context) * 0.05),

            arabicText(
              text: "لوحة التحكم الرئيسية",
              size: getScreenHeight(context) * 0.02,
              color: const Color(0xFF831843),
              bold: true,
            ),
            const SizedBox(height: 10),
            arabicText(
              text: "اختر الخدمة المناسبة من القائمة التالية",
              size: getScreenHeight(context) * 0.015,
              color: const Color(0xFFEB48A0),
              bold: true,
            ),
            SizedBox(height: getScreenHeight(context) * 0.1),

            Container(
              width: getScreenWidth(context) * 0.95,
              padding: EdgeInsets.all(getScreenHeight(context) * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    height: getScreenHeight(context) * 0.1,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFfca5d6),
                          Color(0xFFDBB1FF),
                          Color(0xFFfca5d6),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        arabicText(
                          text: "لوحة الإحصائيات العامة",
                          size: getScreenHeight(context) * 0.02,
                          bold: true,
                          color: const Color(0xFF831843),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.bar_chart,
                          color: Colors.white,
                          size: getScreenHeight(context) * 0.04,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    clipBehavior: Clip.antiAlias,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: StatsHorizontalGrid(items: getStatCards(context)),
                  ),

                  const SizedBox(height: 20),

                  sectionCard(
                    context: context,
                    title: "مخطط مقارنة التشخيصات",
                    trailingIcon: Icons.stacked_bar_chart,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE1EC), Color(0xFFEBD9FF)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    child: Column(
                      children: [
                        DiagnosisComparisonChart(data: chartData, height: 340),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            LegendDot(color: Color(0xFFB36BFF), label: 'عدد'),
                            SizedBox(width: 18),
                            LegendDot(color: Color(0xFFFF5C9A), label: 'نسبة'),
                          ],
                        ),
                        SizedBox(height: getScreenHeight(context) * 0.02),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: getScreenHeight(context) * 0.1),

            sectionCard(
              context: context,
              title: "الخدمات",
              trailingIcon: Icons.dashboard_customize,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE1EC), Color(0xFFEBD9FF)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: HomeFeaturesGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
