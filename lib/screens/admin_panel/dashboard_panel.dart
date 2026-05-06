import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/admin_widgets/dashboard_cards.dart';
import 'package:bahya_website/helper/admin_widgets/roles_distrebuation.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/admin_widgets/activity_panel.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadStatus();
  }

  Future<void> loadStatus() async {
    try {
      final result = await AppRepository().getServiceStatus();

      setState(() {
        status = result;
      });
    } catch (e) {
      setState(() {
        debugPrint("Error fetching service status: $e");
        status = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = getScreenWidth(context);

    int crossAxisCount = 4;

    if (width < 1200) crossAxisCount = 3;
    if (width < 900) crossAxisCount = 2;
    if (width < 600) crossAxisCount = 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeader(
            width: width,
            title: "Dashboard Overview",
            subtitle: "Welcome back, here's what's happening today",
          ),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: width < 1200
                  ? getScreenWidth(context) * 0.145
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

                DashboardCard(
                  icon: Icons.person,
                  title: "Status",
                  value: status,
                  hasPercentage: false,
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
