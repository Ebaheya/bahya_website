import 'dart:ui';

import 'package:bahya_website/helper/admin_widgets/recent%20activity/recent_activity_widgets.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/admin_widgets/recent%20activity/recent_activity_dialog.dart';
import 'package:flutter/material.dart';

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  bool _hover = false;
  bool _pressed = false;

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
    final isMobile = getScreenWidth(context) < 650;
    final scale = _pressed ? 0.98 : (_hover ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.all(
              responsiveSize(context, 0.014, min: 16, max: 22),
            ),
            decoration: BoxDecoration(
              color: _hover ? Colors.grey[50] : Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.016, min: 18, max: 24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hover ? 0.12 : 0.06),
                  blurRadius: responsiveSize(
                    context,
                    _hover ? 0.02 : 0.012,
                    min: 14,
                    max: 28,
                  ),
                  offset: Offset(
                    0,
                    responsiveHeight(
                      context,
                      _hover ? 0.016 : 0.008,
                      min: 6,
                      max: 14,
                    ),
                  ),
                ),
              ],
            ),
            child: Column(
              children: [
                isMobile ? _mobileHeader(context) : _desktopHeader(context),
                SizedBox(
                  height: responsiveHeight(context, 0.025, min: 18, max: 26),
                ),
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

  Widget _desktopHeader(BuildContext context) {
    return Row(
      children: [
        _HeaderIcon(hover: _hover),
        SizedBox(width: responsiveSize(context, 0.012, min: 12, max: 18)),
        customText(
          text: "Recent Activity",
          size: responsiveSize(context, 0.012, min: 17, max: 22),
          color: const Color(0xFF272044),
          bold: true,
          isEnglish: true,
          isCenter: false,
        ),
        const Spacer(),
        _ViewAllButton(
          onTap: () => showRecentActivityDialog(context, activities),
        ),
      ],
    );
  }

  Widget _mobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _HeaderIcon(hover: _hover),
            SizedBox(width: responsiveSize(context, 0.012, min: 12, max: 16)),
            Expanded(
              child: customText(
                text: "Recent Activity",
                size: responsiveSize(context, 0.012, min: 17, max: 20),
                color: const Color(0xFF272044),
                bold: true,
                isEnglish: true,
                isCenter: false,
              ),
            ),
          ],
        ),
        SizedBox(height: responsiveHeight(context, 0.016, min: 12, max: 16)),
        Align(
          alignment: Alignment.centerRight,
          child: _ViewAllButton(
            onTap: () => showRecentActivityDialog(context, activities),
          ),
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final bool hover;

  const _HeaderIcon({required this.hover});

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.038, min: 42, max: 58);

    return AnimatedScale(
      scale: hover ? 1.12 : 1,
      duration: const Duration(milliseconds: 180),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.01, min: 12, max: 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.20),
              blurRadius: responsiveSize(context, 0.012, min: 12, max: 16),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.history_rounded,
          color: Colors.white,
          size: responsiveSize(context, 0.018, min: 22, max: 28),
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.008, min: 10, max: 12),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.011, min: 12, max: 16),
          vertical: responsiveHeight(context, 0.01, min: 8, max: 10),
        ),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.08),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.008, min: 10, max: 12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            customText(
              text: "View All",
              size: responsiveSize(context, 0.008, min: 12, max: 14),
              color: buttonColor,
              bold: true,
              isEnglish: true,
            ),
            SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 9)),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: buttonColor,
              size: responsiveSize(context, 0.008, min: 11, max: 14),
            ),
          ],
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
