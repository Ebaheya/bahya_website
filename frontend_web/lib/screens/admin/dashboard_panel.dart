import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/admin_widgets/dashboard_cards.dart';
import 'package:bahya_website/helper/admin_widgets/page_header.dart';
import 'package:bahya_website/helper/admin_widgets/roles_distrebuation.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/screens/admin/activity_panel.dart';
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

      if (!mounted) return;

      setState(() {
        status = result;
      });
    } catch (e) {
      debugPrint("Error fetching service status: $e");

      if (!mounted) return;

      setState(() {
        status = "Error";
      });
    }
  }

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
        : 4;

    final double cardHeight = isMobile
        ? responsiveHeight(context, 0.16, min: 120, max: 145)
        : isTablet
        ? responsiveHeight(context, 0.15, min: 120, max: 150)
        : responsiveHeight(context, 0.2, min: 165, max: 180);

    final dashboardCards = [
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageHeader(
            context: context,
            icon: Icons.dashboard_rounded,
            title: "Dashboard Overview",
            subtitle: "Welcome back, here's what's happening today",
          ),

          SizedBox(height: responsiveHeight(context, 0.025, min: 16, max: 24)),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboardCards.length,
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
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 350 + (index * 90)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: dashboardCards[index],
              );
            },
          ),

          SizedBox(height: responsiveHeight(context, 0.035, min: 22, max: 32)),

          LayoutBuilder(
            builder: (context, constraints) {
              final bool stackPanels = constraints.maxWidth < 950;

              if (stackPanels) {
                return Column(
                  children: [
                    const RecentActivity(),
                    SizedBox(
                      height: responsiveHeight(
                        context,
                        0.024,
                        min: 16,
                        max: 24,
                      ),
                    ),
                    const UserRolesDistribution(),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(child: RecentActivity()),
                  SizedBox(
                    width: responsiveSize(context, 0.014, min: 16, max: 22),
                  ),
                  const Expanded(child: UserRolesDistribution()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
