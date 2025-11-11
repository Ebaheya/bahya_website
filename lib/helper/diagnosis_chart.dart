import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// موديل بيانات كل عمود
class DiagnosisPoint {
  final String label;
  final double percent; // النسبة
  final double count; // العدد
  DiagnosisPoint(this.label, this.percent, this.count);
}

/// مخطط أعمدة مزدوج (عدد + نسبة)
class DiagnosisComparisonChart extends StatelessWidget {
  final List<DiagnosisPoint> data;
  final double height;
  final EdgeInsetsGeometry? padding;

  const DiagnosisComparisonChart({
    Key? key,
    required this.data,
    this.height = 320,
    this.padding,
  }) : super(key: key);

  static const _colorCount = Color(0xFFB36BFF);
  static const _colorPercent = Color(0xFFFF5C9A);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24),
            child: SizedBox(
              width: data.length * 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calcMaxY(),
                  minY: 0,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 7,
                  ),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = data[group.x.toInt()];
                        final isPercent = rod.color == _colorPercent;
                        final value = rod.toY;
                        return BarTooltipItem(
                          '${item.label}\n'
                          '${isPercent ? "نسبة" : "عدد"}: ${value.toStringAsFixed(0)}${isPercent ? "%" : ""}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontFamily: "ArabicCustomFont",
                          ),
                        );
                      },
                      tooltipPadding: const EdgeInsets.all(8),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: 7,
                        getTitlesWidget: (v, meta) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF9C9C9C),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length)
                            return const SizedBox.shrink();
                          return arabicText(
                            text: data[i].label,
                            size: getScreenHeight(context) * 0.013,
                            bold: true,
                            color: Color(0xFFB30077),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (i) {
                    final item = data[i];
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 8,
                      groupVertically: false,
                      barRods: [
                        BarChartRodData(
                          toY: item.count,
                          width: 26,
                          borderRadius: BorderRadius.circular(6),
                          color: _colorCount,
                        ),
                        BarChartRodData(
                          toY: item.percent,
                          width: 26,
                          borderRadius: BorderRadius.circular(6),
                          color: _colorPercent,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calcMaxY() {
    final maxCount = data.fold<double>(0, (p, e) => e.count > p ? e.count : p);
    final maxPercent = data.fold<double>(
      0,
      (p, e) => e.percent > p ? e.percent : p,
    );
    final m = maxCount > maxPercent ? maxCount : maxPercent;
    return (m + 6).clamp(10, 100);
  }
}
