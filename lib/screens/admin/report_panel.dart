import 'package:bahya_website/helper/admin_widgets/page_header.dart';
import 'package:bahya_website/helper/admin_widgets/reports_table.dart';
import 'package:bahya_website/helper/admin_widgets/reprot_card.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);

    final bool isMobile = width < 650;
    final bool isTablet = width >= 650 && width < 1000;

    final int crossAxisCount = isMobile
        ? 1
        : isTablet
        ? 2
        : width < 1250
        ? 3
        : 3;

    final double cardHeight = isMobile
        ? responsiveHeight(context, 0.16, min: 105, max: 125)
        : isTablet
        ? responsiveHeight(context, 0.11, min: 95, max: 115)
        : responsiveHeight(context, 0.5, min: 82, max: 105);

    final reportsCards = const [
      ReportCard(
        icon: Icons.watch_later_outlined,
        title: "Pending",
        value: 2.0,
      ),
      ReportCard(icon: Icons.error_outline, title: "Investigating", value: 3.0),
      ReportCard(
        icon: Icons.check_circle_outline,
        title: "Resolved",
        value: 4.0,
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 22)),
      child: Column(
        children: [
          pageHeader(
            context: context,
            title: 'Reports Management',
            subtitle: 'Review and resolve user reports',
            icon: Icons.report_rounded,
          ),

          SizedBox(height: responsiveHeight(context, 0.025, min: 16, max: 24)),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reportsCards.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: responsiveSize(
                context,
                0.012,
                min: 12,
                max: 18,
              ),
              mainAxisSpacing: responsiveHeight(
                context,
                0.018,
                min: 12,
                max: 18,
              ),
              mainAxisExtent: cardHeight,
            ),
            itemBuilder: (context, index) => reportsCards[index],
          ),

          SizedBox(height: responsiveHeight(context, 0.025, min: 16, max: 24)),

          const ReportsTable(),
        ],
      ),
    );
  }
}
