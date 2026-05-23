import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserRolesDistribution extends StatefulWidget {
  const UserRolesDistribution({super.key});

  @override
  State<UserRolesDistribution> createState() => _UserRolesDistributionState();
}

class _UserRolesDistributionState extends State<UserRolesDistribution> {
  bool _hover = false;
  bool _pressed = false;

  void _setHover(bool v) => setState(() => _hover = v);

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.98 : (_hover ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),

        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,

          child: AnimatedContainer(
            width: double.infinity,
            height: getScreenHeight(context) * 0.45,
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hover ? 0.12 : 0.06),
                  blurRadius: _hover ? 28 : 14,
                  offset: Offset(0, _hover ? 14 : 6),
                ),
              ],
            ),

            child: SizedBox(
              height: getScreenHeight(context) * 0.36,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      AnimatedScale(
                        scale: _hover ? 1.12 : 1,
                        duration: const Duration(milliseconds: 180),

                        child: Container(
                          width: getScreenWidth(context) * 0.035,
                          height: getScreenWidth(context) * 0.035,

                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradientColors),
                            borderRadius: BorderRadius.circular(14),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.20),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: const Icon(
                            Icons.pie_chart_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),

                      SizedBox(width: getScreenWidth(context) * 0.012),

                      customText(
                        text: "User Roles Distribution",
                        size: getScreenWidth(context) * 0.012,
                        color: const Color(0xFF272044),
                        bold: true,
                        isEnglish: true,
                      ),
                    ],
                  ),

                  SizedBox(height: getScreenHeight(context) * 0.025),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              ModernLegendItem(
                                color: Colors.purple,
                                title: "Doctors",
                                percent: "62%",
                              ),

                              SizedBox(height: 18),

                              ModernLegendItem(
                                color: Colors.blue,
                                title: "Nurses",
                                percent: "18%",
                              ),

                              SizedBox(height: 18),

                              ModernLegendItem(
                                color: Colors.green,
                                title: "Staff",
                                percent: "12%",
                              ),

                              SizedBox(height: 18),

                              ModernLegendItem(
                                color: Colors.pink,
                                title: "Admins",
                                percent: "8%",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 30),
                        Expanded(flex: 2, child: RolesChart(isHover: _hover)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RolesChart extends StatefulWidget {
  final bool isHover;

  const RolesChart({super.key, required this.isHover});

  @override
  State<RolesChart> createState() => _RolesChartState();
}

class _RolesChartState extends State<RolesChart> {
  int touchedIndex = -1;

  final List<Map<String, dynamic>> data = [
    {"title": "Doctors", "percent": 62.0, "color": Colors.purple},
    {"title": "Nurses", "percent": 18.0, "color": Colors.blue},
    {"title": "Staff", "percent": 12.0, "color": Colors.green},
    {"title": "Admins", "percent": 8.0, "color": Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.isHover ? 1.04 : 1),

      duration: const Duration(milliseconds: 200),

      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,

          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: getScreenHeight(context) * 0.02,

              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }

                    touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),

              sections: List.generate(data.length, (index) {
                final item = data[index];

                final isTouched = index == touchedIndex;

                return PieChartSectionData(
                  value: item["percent"],

                  color: item["color"],

                  radius: isTouched
                      ? getScreenHeight(context) * 0.14
                      : getScreenHeight(context) * 0.13,

                  title: "${item["percent"].toInt()}%",

                  titleStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ArabicCustomFont',

                    fontSize: getScreenWidth(context) * 0.010,
                  ),

                  badgeWidget: isTouched
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                              ),
                            ],
                          ),

                          child: customText(
                            text: item["title"],
                            size: getScreenWidth(context) * 0.009,
                            color: textColor,
                            bold: true,
                            isEnglish: true,
                          ),
                        )
                      : null,
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class ModernLegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String percent;

  const ModernLegendItem({
    super.key,
    required this.color,
    required this.title,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(color: color.withOpacity(0.25), blurRadius: 6),
            ],
          ),
        ),
        Expanded(
          child: customText(
            text: title,
            size: getScreenWidth(context) * 0.01,
            color: const Color(0xFF272044),
            bold: true,
            isEnglish: true,
          ),
        ),
        Spacer(),
        customText(
          text: percent,
          size: getScreenWidth(context) * 0.009,
          color: Colors.grey,
          bold: true,
          isEnglish: true,
        ),
      ],
    );
  }
}
