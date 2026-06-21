import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserRolesDistribution extends StatefulWidget {
  final Map<String, dynamic> roles;

  const UserRolesDistribution({super.key, this.roles = const {}});

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
    final data = _buildRolesData(widget.roles);

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
                  color: Colors.black.withValues(alpha: _hover ? 0.12 : 0.06),
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
                  child: data.isEmpty
                      ? const Center(child: Text("No role data available"))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 700;

                            if (isSmall) {
                              return Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: RolesChart(
                                      isHover: _hover,
                                      data: data,
                                    ),
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.012,
                                      min: 8,
                                      max: 14,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _RolesLegendList(
                                      isMobile: true,
                                      data: data,
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _RolesLegendList(
                                    isMobile: false,
                                    data: data,
                                  ),
                                ),
                                SizedBox(
                                  width: responsiveSize(
                                    context,
                                    0.02,
                                    min: 16,
                                    max: 30,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: RolesChart(
                                    isHover: _hover,
                                    data: data,
                                  ),
                                ),
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

  List<Map<String, dynamic>> _buildRolesData(Map<String, dynamic> roles) {
    final colors = <Color>[
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.pink,
      Colors.orange,
    ];

    final total = roles.values.fold<num>(0, (sum, value) {
      if (value is num) return sum + value;
      return sum + (num.tryParse(value.toString()) ?? 0);
    });

    if (total <= 0) return [];

    int index = 0;

    return roles.entries.map((entry) {
      final count = entry.value is num
          ? entry.value as num
          : num.tryParse(entry.value.toString()) ?? 0;

      final percent = (count / total) * 100;
      final item = {
        "title": _formatRole(entry.key),
        "count": count,
        "percent": percent,
        "color": colors[index % colors.length],
      };

      index++;
      return item;
    }).toList();
  }

  String _formatRole(String role) {
    return role
        .toLowerCase()
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? word : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
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
  final List<Map<String, dynamic>> data;

  const _RolesLegendList({required this.isMobile, required this.data});

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
      children: List.generate(data.length, (index) {
        final item = data[index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == data.length - 1 ? 0 : spacing,
          ),
          child: ModernLegendItem(
            color: item["color"],
            title: item["title"],

          ),
        );
      }),
    );
  }
}

class RolesChart extends StatefulWidget {
  final bool isHover;
  final List<Map<String, dynamic>> data;

  const RolesChart({super.key, required this.isHover, required this.data});

  @override
  State<RolesChart> createState() => _RolesChartState();
}

class _RolesChartState extends State<RolesChart> {
  int touchedIndex = -1;

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
                      sections: List.generate(widget.data.length, (index) {
                        final item = widget.data[index];
                        final isTouched = index == touchedIndex;
                        final percent = item["percent"] as double;

                        return PieChartSectionData(
                          value: percent,
                          color: item["color"],
                          radius: isTouched ? 88 : 78,
                          title: "${percent.toStringAsFixed(0)}%",
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

  const ModernLegendItem({
    super.key,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start ,
      children: [
        Container(
          width: responsiveSize(context, 0.012, min: 12, max: 18),
          height: responsiveSize(context, 0.012, min: 12, max: 18),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 14)),
        customText(
          text: title,
          size: responsiveSize(context, 0.01, min: 12, max: 16),
          color: const Color(0xFF272044),
          bold: true,
          isEnglish: true,
          isCenter: false,
          maxLines: 1,
        ),
      ],
    );
  }
}
