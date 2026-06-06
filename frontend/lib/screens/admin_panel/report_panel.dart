import 'package:bahya_website/helper/admin_widgets/report_table.dart';
import 'package:bahya_website/helper/admin_widgets/reprot_card.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = getScreenWidth(context);
    double height = getScreenHeight(context);
    int crossAxisCount = 4;
    if (width < 1200) crossAxisCount = 3;
    if (width < 900) crossAxisCount = 2;
    if (width < 600) crossAxisCount = 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          pageHeader(
              height: height,
            width: width,
            title: 'Reports Management',
            subtitle: 'Review and resolve user reports',
            icon: Icons.report_rounded,
          ),
          const SizedBox(height: 20),

          /// Cards Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: width < 1200
                  ? getScreenWidth(context) * 0.067
                  : getScreenWidth(context) * 0.05,
            ),
            itemBuilder: (context, index) {
              final items = [
                const ReportCard(
                  icon: Icons.watch_later_outlined,
                  title: "Pending",
                  value: 2.0,
                ),
                const ReportCard(
                  icon: Icons.error_outline,
                  title: "Investigating",
                  value: 3.0,
                ),
                const ReportCard(
                  icon: Icons.check_circle_outline,
                  title: "Resolved",
                  value: 4.0,
                ),
                // const ReportCard(
                //   icon: Icons.warning_amber_rounded,
                //   title: "Critical",
                //   value: 1.0,
                // ),
              ];
              return items[index];
            },
          ),
          const SizedBox(height: 20),
          ReportsTable(),
        ],
      ),
    );
  }
}
