import 'dart:developer';
import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/diagnosis_chart.dart';
import 'package:bahya_website/helper/widgets/home_drawer.dart';
import 'package:bahya_website/helper/widgets/home_feature_grid.dart';
import 'package:bahya_website/helper/widgets/state_card.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
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
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: HomeDrawer(userName: userName),
      appBar: customAppBar(
        context: context,
        title: 'Psychological Support Team',
        isHomeBar: true,
        scaffoldKey: _scaffoldKey,
      ),
      backgroundColor: const Color(0xFFFDF7FB),
      body: ValueListenableBuilder<Locale>(
        valueListenable: AppLanguageController.localeNotifier,
        builder: (context, locale, _) {
          final isEnglish = locale.languageCode == 'en';

          return Directionality(
            textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: h * 0.02),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.025),
                    child: Align(
                      alignment: isEnglish
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: const LanguageToggleButton(
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  customText(
                    text: "Main dashboard",
                    size: h * 0.02,
                    color: const Color(0xFF831843),
                    bold: true,
                  ),
            const SizedBox(height: 10),
            customText(
              text: "Choose the right service from the list below",
              size: h * 0.015,
              color: const Color(0xFFEB48A0),
              bold: true,
            ),
            SizedBox(height: h * 0.03),

            Center(
              child: Container(
                width: w * 0.95,
                padding: EdgeInsets.all(h * 0.02),
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
                    sectionCard(
                      isShadow: false,
                      context: context,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: StatsHorizontalGrid(
                          items: getStatCards(context),
                        ),
                      ),
                      title: "General statistics dashboard",
                    ),

                    SizedBox(height: h * 0.01),

                    sectionCard(
                      context: context,
                      title: "Diagnosis comparison chart",
                      child: Column(
                        children: [
                          DiagnosisComparisonChart(
                            data: chartData,
                            height: h * 0.5,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LegendDot(
                                color: Color(0xFFB36BFF),
                                label: 'Count',
                              ),
                              SizedBox(width: 18),
                              LegendDot(
                                color: Color(0xFFFF5C9A),
                                label: 'Percent',
                              ),
                            ],
                          ),
                          SizedBox(height: h * 0.02),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: h * 0.1),

            sectionCard(
              context: context,
              title: "Services",
              child: Padding(
                padding: EdgeInsets.all(16),
                child: HomeFeaturesGrid(),
              ),
            ),
            SizedBox(height: h * 0.02),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
