import 'package:bahya_website/helper/admin_widgets/dashboard_cards.dart';
import 'package:bahya_website/helper/admin_widgets/roles_distrebuation.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/admin_widgets/activity_panel.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    int crossAxisCount = 4;
    if (width < 1200) crossAxisCount = 3;
    if (width < 900) crossAxisCount = 2;
    if (width < 600) crossAxisCount = 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: gradientColors),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: "Dashboard Overview",
                  size: width * 0.013,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                customText(
                  text: "Welcome back, here's what's happening today",
                  color: Colors.white54,
                  size: width * 0.01,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Cards Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: width < 1000
                  ? getScreenWidth(context) * 0.125
                  : getScreenWidth(context) * 0.095,
            ),
            itemBuilder: (context, index) {
              final items = [
                const DashboardCard(
                  icon: Icons.people,
                  title: "Total Users",
                  value: "2,847",
                  percentage: 12.5,
                ),
                const DashboardCard(
                  icon: Icons.waves,
                  title: "Active Users",
                  value: "1.2234",
                  percentage: 8.3,
                ),
                const DashboardCard(
                  icon: Icons.person,
                  title: "Status",
                  value: "Healthy",
                  percentage: 98.5,
                ),
                const DashboardCard(
                  icon: Icons.wallet_membership_outlined,
                  title: "Reports",
                  value: "310",
                  percentage: -3.7,
                ),
              ];

              return items[index];
            },
          ),

          const SizedBox(height: 30),

          /// Bottom Section
          Row(
            children: [
              Expanded(child: RecentActivity()),
              const SizedBox(width: 20),
              Expanded(child: UserRolesDistribution()),
            ],
          ),
        ],
      ),
    );
  }
}





