import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserRolesDistribution extends StatelessWidget {
  const UserRolesDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: getScreenHeight(context) * 0.35,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: "User Roles Distribution",
              size: getScreenHeight(context) * 0.025,
              color: textColor,
              bold: true,
              isEnglish: true,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Row(
                children: [
                  /// Chart
                  Expanded(flex: 2, child: RolesChart()),

                  // const SizedBox(width: 40),

                  /// Legend
                  // Expanded(
                  //   flex: 1,
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       LegendItem(color: Colors.purple, text: "Patients 65%"),
                  //       const SizedBox(height: 10),
                  //       LegendItem(color: Colors.blue, text: "Therapists 18%"),
                  //       const SizedBox(height: 10),
                  //       LegendItem(color: Colors.pink, text: "Admins 6%"),
                  //       const SizedBox(height: 10),
                  //       LegendItem(color: Colors.green, text: "Support 11%"),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RolesChart extends StatefulWidget {
  const RolesChart({super.key});

  @override
  State<RolesChart> createState() => _RolesChartState();
}

class _RolesChartState extends State<RolesChart> {
  int touchedIndex = -1;

  final List<Map<String, dynamic>> data = [
    {
      "title": "Patients",
      "value": 1850,
      "percent": 65.0,
      "color": Colors.purple,
    },
    {
      "title": "Therapists",
      "value": 520,
      "percent": 18.0,
      "color": Colors.blue,
    },
    {"title": "Admins", "value": 170, "percent": 6.0, "color": Colors.pink},
    {"title": "Support", "value": 310, "percent": 11.0, "color": Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 0,
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
            badgeWidget: isTouched
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: customText(
                      text: "${item["title"]}: ${item["value"]}",
                      size: getScreenHeight(context) * 0.02,
                      color: textColor,
                    ),
                  )
                : null,
            // badgePositionPercentageOffset: ,
            // titlePositionPercentageOffset: 1.15,
            radius: isTouched
                ? getScreenHeight(context) * 0.16
                : getScreenHeight(context) * 0.15,
            title: '',
          );
        }),
      ),
    );
  }
}

// class LegendItem extends StatelessWidget {
//   final Color color;
//   final String text;

//   const LegendItem({super.key, required this.color, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(3),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
//       ],
//     );
//   }
// }
