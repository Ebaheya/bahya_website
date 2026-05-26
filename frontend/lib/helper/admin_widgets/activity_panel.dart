import 'dart:ui';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/screens/admin_panel/all_activity.dart';
import 'package:flutter/material.dart';

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  bool _hover = false;
  bool _pressed = false;

  void _setHover(bool v) => setState(() => _hover = v);
  void _setPressed(bool v) => setState(() => _pressed = v);

  final List<ActivityModel> activities = [
    ActivityModel(
      dotColor: Colors.purple,
      iconColor: Colors.purple,
      icon: Icons.description_outlined,
      title: "Dr. Sarah Johnson",
      description: "Updated patient record",
      time: "2 minutes ago",
    ),
    ActivityModel(
      dotColor: Colors.pink,
      iconColor: Colors.pink,
      icon: Icons.cloud_upload_outlined,
      title: "Dr. Mohammed",
      description: "Failed to upload document",
      time: "32 minutes ago",
    ),
    ActivityModel(
      dotColor: Colors.grey,
      iconColor: Colors.grey,
      icon: Icons.settings_rounded,
      title: "Dr. Ahmed Johnson",
      description: "Modified system settings",
      time: "42 minutes ago",
    ),
    ActivityModel(
      dotColor: Colors.blue,
      iconColor: Colors.blue,
      icon: Icons.person_add_alt_1_rounded,
      title: "Dr. Emily Davis",
      description: "Added new patient",
      time: "1 hour ago",
    ),
    ActivityModel(
      dotColor: Colors.green,
      iconColor: Colors.green,
      icon: Icons.download_rounded,
      title: "Dr. Michael Brown",
      description: "Exported patient report",
      time: "2 hours ago",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    final scale = _pressed ? 0.98 : (_hover ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _hover ? Colors.grey[50] : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hover ? 0.12 : 0.06),
                  blurRadius: _hover ? 28 : 14,
                  offset: Offset(0, _hover ? 14 : 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AnimatedScale(
                      scale: _hover ? 1.12 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: Container(
                        width: w * 0.035,
                        height: w * 0.035,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.20),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),

                    SizedBox(width: w * 0.012),

                    customText(
                      text: "Recent Activity",
                      size: w * 0.012,
                      color: const Color(0xFF272044),
                      bold: true,
                      isEnglish: true,
                    ),

                    const Spacer(),

                    InkWell(
                      onTap: () {
                        showRecentActivityDialog(context, activities);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            customText(
                              text: "View All",
                              size: w * 0.008,
                              color: buttonColor,
                              bold: true,
                              isEnglish: true,
                            ),
                            SizedBox(width: w * 0.006),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: buttonColor,
                              size: w * 0.008,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: h * 0.025),

              Column(
                  children: List.generate(
                    activities.length >= 3 ? 3 : activities.length,
                    (index) {
                      final item = activities[index];

                      return ActivityItem(
                        dotColor: item.dotColor,
                        iconColor: item.iconColor,
                        icon: item.icon,
                        title: item.title,
                        description: item.description,
                        time: item.time,
                        showLine: index != 2,
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
}

void showRecentActivityDialog(
  BuildContext context,
  List<ActivityModel> activities,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Recent Activity",
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) {
      return RecentActivityDialog(activities: activities);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

