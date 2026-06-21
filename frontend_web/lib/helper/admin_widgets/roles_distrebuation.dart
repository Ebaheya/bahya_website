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

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;
    final scale = _pressed ? 0.98 : (_hover ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            width: double.infinity,
           
            height: responsiveHeight(
              context,
              isMobile ? 0.40 : 0.53,
              min: isMobile ? 370 : 420,
              max: isMobile ? 620 : 560,
            ),
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.all(
              responsiveSize(context, 0.014, min: 14, max: 22),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.018, min: 20, max: 24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hover ? 0.12 : 0.06),
                  blurRadius: responsiveSize(
                    context,
                    _hover ? 0.024 : 0.014,
                    min: 14,
                    max: 28,
                  ),
                  offset: Offset(
                    0,
                    responsiveHeight(
                      context,
                      _hover ? 0.016 : 0.008,
                      min: 6,
                      max: 14,
                    ),
                  ),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RolesHeader(hover: _hover),
                SizedBox(
                  height: responsiveHeight(context, 0.018, min: 12, max: 22),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmall = constraints.maxWidth < 700;

                      if (isSmall) {
                        return Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: RolesChart(isHover: _hover),
                            ),
                            SizedBox(
                              height: responsiveHeight(
                                context,
                                0.012,
                                min: 8,
                                max: 14,
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: _RolesLegendList(isMobile: true),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: _RolesLegendList(isMobile: false),
                          ),
                          SizedBox(
                            width: responsiveSize(
                              context,
                              0.02,
                              min: 16,
                              max: 30,
                            ),
                          ),
                          Expanded(flex: 2, child: RolesChart(isHover: _hover)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RolesHeader extends StatelessWidget {
  final bool hover;

  const _RolesHeader({required this.hover});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedScale(
          scale: hover ? 1.12 : 1,
          duration: const Duration(milliseconds: 180),
          child: Container(
            width: responsiveSize(context, 0.035, min: 40, max: 60),
            height: responsiveSize(context, 0.035, min: 40, max: 60),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.012, min: 12, max: 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.20),
                  blurRadius: responsiveSize(context, 0.012, min: 12, max: 16),
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.pie_chart_rounded,
              color: Colors.white,
              size: responsiveSize(context, 0.018, min: 20, max: 28),
            ),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 18)),
        Expanded(
          child: customText(
            text: "User Roles Distribution",
            size: responsiveSize(context, 0.012, min: 14, max: 22),
            color: const Color(0xFF272044),
            bold: true,
            isEnglish: true,
            isCenter: false,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _RolesLegendList extends StatelessWidget {
  final bool isMobile;

  const _RolesLegendList({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final spacing = responsiveHeight(
      context,
      isMobile ? 0.012 : 0.02,
      min: isMobile ? 8 : 14,
      max: isMobile ? 12 : 18,
    );

    return Column(
      mainAxisAlignment: isMobile
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModernLegendItem(
          color: Colors.purple,
          title: "Doctors",
          percent: "62%",
        ),
        SizedBox(height: spacing),
        const ModernLegendItem(
          color: Colors.blue,
          title: "Nurses",
          percent: "18%",
        ),
        SizedBox(height: spacing),
        const ModernLegendItem(
          color: Colors.green,
          title: "Staff",
          percent: "12%",
        ),
        SizedBox(height: spacing),
        const ModernLegendItem(
          color: Colors.pink,
          title: "Admins",
          percent: "8%",
        ),
      ],
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
      tween: Tween(begin: 0, end: widget.isHover ? 1.03 : 1),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Center(
          child: Transform.scale(
            scale: scale,
            child: AspectRatio(
              aspectRatio: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 32,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }

                            touchedIndex =
                                response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: List.generate(data.length, (index) {
                        final item = data[index];
                        final isTouched = index == touchedIndex;

                        return PieChartSectionData(
                          value: item["percent"],
                          color: item["color"],
                          radius: isTouched ? 88 : 78,
                          title: "${item["percent"].toInt()}%",
                          titleStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'ArabicCustomFont',
                            fontSize: responsiveSize(
                              context,
                              0.01,
                              min: 11,
                              max: 15,
                            ),
                          ),
                          badgeWidget: isTouched
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: responsiveSize(
                                      context,
                                      0.008,
                                      min: 8,
                                      max: 10,
                                    ),
                                    vertical: responsiveHeight(
                                      context,
                                      0.006,
                                      min: 5,
                                      max: 6,
                                    ),
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
                                    size: responsiveSize(
                                      context,
                                      0.009,
                                      min: 11,
                                      max: 14,
                                    ),
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
                ),
              ),
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
          width: responsiveSize(context, 0.012, min: 12, max: 18),
          height: responsiveSize(context, 0.012, min: 12, max: 18),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.25), blurRadius: 6),
            ],
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.01, min: 10, max: 14)),
        Expanded(
          child: customText(
            text: title,
            size: responsiveSize(context, 0.01, min: 12, max: 16),
            color: const Color(0xFF272044),
            bold: true,
            isEnglish: true,
            isCenter: false,
            maxLines: 1,
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 12)),
        customText(
          text: percent,
          size: responsiveSize(context, 0.009, min: 11, max: 14),
          color: Colors.grey,
          bold: true,
          isEnglish: true,
        ),
      ],
    );
  }
}
