import 'package:bahya_website/helper/base.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressLineChart extends StatelessWidget {
  final bool weekly;
  const ProgressLineChart({required this.weekly});

  @override
  Widget build(BuildContext context) {
    final spotsDepression = [
      const FlSpot(0, 48),
      const FlSpot(1, 45),
      const FlSpot(2, 42),
      const FlSpot(3, 39),
      const FlSpot(4, 36),
      const FlSpot(5, 33),
      const FlSpot(6, 31),
    ];
    final spotsAnxiety = [
      const FlSpot(0, 46),
      const FlSpot(1, 43),
      const FlSpot(2, 40),
      const FlSpot(3, 37),
      const FlSpot(4, 34),
      const FlSpot(5, 31),
      const FlSpot(6, 30),
    ];

    final labels = weekly
        ? [
            "1 أسبوع",
            "2 أسبوع",
            "3 أسبوع",
            "4 أسبوع",
            "5 أسبوع",
            "6 أسبوع",
            "الأسبوع الحالي",
          ]
        : ["شهر 1", "شهر 2", "شهر 3", "شهر 4", "شهر 5", "شهر 6", "الحالي"];

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: const BoxDecoration(color: Colors.white),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 6,
            minY: 30,
            maxY: 60,
            backgroundColor: Colors.transparent,
            borderData: FlBorderData(show: false),

            gridData: FlGridData(
              show: true,
              verticalInterval: 1,
              horizontalInterval: 5,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (v) =>
                  FlLine(color: Colors.grey.withOpacity(0.06), strokeWidth: 1),
              getDrawingVerticalLine: (v) =>
                  FlLine(color: Colors.grey.withOpacity(0.06), strokeWidth: 1),
            ),

            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBorderRadius: BorderRadius.circular(14),
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                tooltipMargin: 10,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipColor: (spot) => Colors.white,
                getTooltipItems: (touchedSpots) {
                  if (touchedSpots.isEmpty) return [];

                  final xIndex = touchedSpots.first.x.toInt();
                  final weekLabel =
                      labels[xIndex.clamp(
                        0,
                        labels.length - 1,
                      )]; 

                  final children = <TextSpan>[];

                  children.add(
                    TextSpan(
                      text: "$weekLabel\n",
                      style: const TextStyle(
                        fontFamily: "ArabicCustomFont",
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                  );

                  for (final s in touchedSpots) {
                    final isDepression = s.barIndex == 0;
                    final color = isDepression
                        ? const Color(0xFFFB7185)
                        : const Color(0xFFA855F7);
                    final label = isDepression ? "الاكتئاب" : "القلق";
                    final value = s.y.toInt();

                    children.add(
                      TextSpan(
                        text: "● ",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    );

                    children.add(
                      TextSpan(
                        text: "%$value :$label\n",
                        style: TextStyle(
                          fontFamily: "ArabicCustomFont",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    );
                  }

                  final firstItem = LineTooltipItem(
                    '',
                    const TextStyle(),
                    children: children,
                  );
                  return [
                    firstItem,
                    ...List<LineTooltipItem?>.filled(
                      touchedSpots.length - 1,
                      null,
                    ),
                  ];
                },
              ),
              getTouchedSpotIndicator:
                  (LineChartBarData bar, List<int> spotIndexes) {
                    return spotIndexes
                        .map(
                          (i) => TouchedSpotIndicatorData(
                            FlLine(color: Colors.transparent),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                  strokeColor: bar.color ?? Colors.cyan,
                                );
                              },
                            ),
                          ),
                        )
                        .toList();
                  },
            ),

            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  getTitlesWidget: (v, _) => arabicText(
                    text: v.toInt().toString(),
                    size: 10,
                    color: const Color(0xffDD59F1),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: arabicText(
                        text: labels[i],
                        size: 8,
                        color: const Color(0xffDD59F1),
                      ),
                    );
                  },
                ),
              ),
            ),

            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                barWidth: 3,
                color: const Color(0xFFA855F7),
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                spots: spotsDepression,
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFFA855F7).withOpacity(0.25),
                ),
              ),
              LineChartBarData(
                isCurved: true,
                barWidth: 3,
                color: const Color(0xFFFB7185),
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                spots: spotsAnxiety,
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFFFB7185).withOpacity(0.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
