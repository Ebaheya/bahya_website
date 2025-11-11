import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/state_card.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homePageAppBar(context: context),
      backgroundColor: const Color(0xFFFDF7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getScreenHeight(context) * 0.05),
            Column(
              children: [
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
              ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
