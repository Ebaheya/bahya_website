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
  bool isLoading = true;
  String? errorMessage;

  int totalUsers = 0;
  int activeUsers = 0;
  int openReports = 0;
  int openNotifications = 0;
  Map<String, dynamic> usersByRole = {};
  Map<String, dynamic> assessmentsByStatus = {};
  List<dynamic> activity = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final repo = AppRepository();

      final results = await Future.wait([
        repo.getDashboardSummary(),
        repo.getDashboardActivity(limit: 10),
      ]);

      final summary = results[0];
      final activityResult = results[1];

      final users = Map<String, dynamic>.from(summary['users'] ?? {});
      final reports = Map<String, dynamic>.from(summary['reports'] ?? {});
      final notifications = Map<String, dynamic>.from(
        summary['notifications'] ?? {},
      );
      final assessments = Map<String, dynamic>.from(
        summary['assessments'] ?? {},
      );

      if (!mounted) return;

      setState(() {
        totalUsers = users['total'] ?? 0;
        activeUsers = users['active'] ?? 0;
        openReports = reports['open'] ?? 0;
        openNotifications = notifications['open'] ?? 0;
        usersByRole = _filterRoles(users['byRole']);
        assessmentsByStatus = Map<String, dynamic>.from(
          assessments['byStatus'] ?? {},
        );
        activity = List<dynamic>.from(activityResult['data'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Map<String, dynamic> _filterRoles(dynamic rawRoles) {
    final roles = Map<String, dynamic>.from(rawRoles ?? {});

    roles.removeWhere((key, value) {
      final normalizedKey = key.toString().toUpperCase();
      return normalizedKey == 'CALL_CENTER' ||
          normalizedKey == 'CALLCENTER' ||
          normalizedKey == 'CALL CENTER';
    });

    return roles;
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
        ? responsiveHeight(context, 0.16, min: 155, max: 160)
        : isTablet
        ? responsiveHeight(context, 0.15, min: 155, max: 160)
        : responsiveHeight(context, 0.2, min: 187, max: 190);

    final dashboardCards = [
      DashboardCard(
        icon: Icons.people,
        title: "Total Users",
        value: totalUsers.toString(),
        hasPercentage: false,
      ),
      DashboardCard(
        icon: Icons.waves,
        title: "Active Users",
        value: activeUsers.toString(),
        hasPercentage: false,
      ),
      DashboardCard(
        icon: Icons.report_problem_outlined,
        title: "Open Reports",
        value: openReports.toString(),
        hasPercentage: false,
      ),
      DashboardCard(
        icon: Icons.notifications_active_outlined,
        title: "Open Notifications",
        value: openNotifications.toString(),
        hasPercentage: false,
      ),
    ];

    return RefreshIndicator(
      onRefresh: loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(
          responsiveSize(context, 0.014, min: 14, max: 22),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.sizeOf(context).height -
                responsiveHeight(context, 0.08, min: 60, max: 90),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pageHeader(
                context: context,
                icon: Icons.dashboard_rounded,
                title: "Dashboard Overview",
                subtitle: "Welcome back, here's what's happening today",
              ),
              SizedBox(
                height: responsiveHeight(context, 0.025, min: 16, max: 24),
              ),
              if (isLoading)
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.65,
                  child: customLoading(),
                )
              else if (errorMessage != null)
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.65,
                  child: Center(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else ...[
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
                SizedBox(
                  height: responsiveHeight(context, 0.035, min: 22, max: 32),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool stackPanels = constraints.maxWidth < 950;

                    if (stackPanels) {
                      return Column(
                        children: [
                          RecentActivity(activity: activity),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.024,
                              min: 16,
                              max: 24,
                            ),
                          ),
                          UserRolesDistribution(roles: usersByRole),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: RecentActivity(activity: activity)),
                        SizedBox(
                          width: responsiveSize(
                            context,
                            0.014,
                            min: 16,
                            max: 22,
                          ),
                        ),
                        Expanded(
                          child: UserRolesDistribution(roles: usersByRole),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
