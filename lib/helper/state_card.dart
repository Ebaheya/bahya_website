import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double percent;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.percent,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color, size: 26),
            ),
            CircularPercentIndicator(
              radius: 50,
              lineWidth: 8,
              animation: true,
              percent: percent,
              center: arabicText(
                text: "${percent * 100}%",
                size: 18,
                bold: true,
              ),
              circularStrokeCap: CircularStrokeCap.round,
              animateFromLastPercent: true,
              animateToInitialPercent: true,
              backgroundColor: Colors.grey.shade200,
              progressColor: color,
            ),
            Column(
              children: [
                arabicText(
                  text: title,
                  size: 18,
                  bold: true,
                  color: Color(0xFF7A004C),
                ),
                const SizedBox(height: 4),
                arabicText(
                  text: "من إجمالي المرضى",
                  size: 13,
                  color: Colors.black45,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatsHorizontalGrid extends StatelessWidget {
  final List<StatCard> items;
  const StatsHorizontalGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getScreenHeight(context) * 0.35,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.stylus,
          },
        ),
        child: GridView.builder(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 20,

            // mainAxisExtent: ,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }
}

List<StatCard> getStatCards(BuildContext context) {
  return [
    StatCard(
      title: "حالات طبيعية",
      percent: .27,
      color: Colors.green,
      icon: Icons.emoji_emotions,
    ),
    StatCard(
      title: "اضطراب نفسي عام",
      percent: .20,
      color: Colors.blue,
      icon: Icons.monitor_heart,
    ),
    StatCard(
      title: "القلق",
      percent: .27,
      color: Colors.purple,
      icon: Icons.psychology,
    ),
    StatCard(
      title: "الاكتئاب",
      percent: .27,
      color: Colors.pink,
      icon: Icons.favorite,
    ),
    StatCard(
      title: "حالات طبيعية",
      percent: .27,
      color: Colors.green,
      icon: Icons.emoji_emotions,
    ),
    StatCard(
      title: "اضطراب نفسي عام",
      percent: .20,
      color: Colors.blue,
      icon: Icons.monitor_heart,
    ),
    StatCard(
      title: "القلق",
      percent: .27,
      color: Colors.purple,
      icon: Icons.psychology,
    ),
    StatCard(
      title: "الاكتئاب",
      percent: .27,
      color: Colors.pink,
      icon: Icons.favorite,
    ),
  ];
}
