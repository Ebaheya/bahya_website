import 'dart:ui';

import 'package:bahya_website/helper/admin_widgets/recent%20activity/recent_activity_dialog.dart';
import 'package:bahya_website/helper/admin_widgets/recent%20activity/recent_activity_widgets.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class RecentActivity extends StatefulWidget {
  final List<dynamic> activity;

  const RecentActivity({super.key, this.activity = const []});

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;
    final scale = _pressed ? 0.98 : (_hover ? 1.02 : 1.0);
    final activities = _mapActivities(widget.activity);

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
                isMobile
                    ? _mobileHeader(context, activities)
                    : _desktopHeader(context, activities),
                SizedBox(
                  height: responsiveHeight(context, 0.025, min: 18, max: 26),
                ),
                if (activities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("No recent activity available"),
                  )
                else
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
                          showLine:
                              index != 2 && index != activities.length - 1,
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

  List<ActivityModel> _mapActivities(List<dynamic> rawItems) {
    return rawItems.map((item) {
      final map = item is Map
          ? Map<String, dynamic>.from(item)
          : <String, dynamic>{};
      final actor = map['actor'] is Map
          ? Map<String, dynamic>.from(map['actor'])
          : null;

      final action = map['action']?.toString() ?? 'SYSTEM_ACTIVITY';
      final entityType = map['entityType']?.toString() ?? 'SYSTEM';
      final createdAt = map['createdAt']?.toString();

      return ActivityModel(
        dotColor: _activityColor(action),
        iconColor: _activityColor(action),
        icon: _activityIcon(action),
        title: actor?['fullName']?.toString() ?? 'System',
        description: _formatAction(action, entityType),
        time: _formatTime(createdAt),
      );
    }).toList();
  }

  Color _activityColor(String action) {
    if (action.contains('CREATED')) return Colors.green;
    if (action.contains('UPDATED') || action.contains('CHANGED'))
      return Colors.blue;
    if (action.contains('FAILED')) return Colors.red;
    if (action.contains('REPORT')) return Colors.pink;
    if (action.contains('ASSESSMENT')) return Colors.purple;
    return Colors.grey;
  }

  IconData _activityIcon(String action) {
    if (action.contains('CREATED')) return Icons.add_circle_outline;
    if (action.contains('UPDATED') || action.contains('CHANGED'))
      return Icons.edit_outlined;
    if (action.contains('FAILED')) return Icons.error_outline;
    if (action.contains('REPORT')) return Icons.report_problem_outlined;
    if (action.contains('ASSESSMENT')) return Icons.assignment_outlined;
    if (action.contains('PATIENT')) return Icons.person_outline;
    return Icons.history_rounded;
  }

  String _formatAction(String action, String entityType) {
    final readableAction = action.toLowerCase().replaceAll('_', ' ');
    final readableEntity = entityType.toLowerCase().replaceAll('_', ' ');
    return "$readableAction on $readableEntity";
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final diff = DateTime.now().difference(date.toLocal());

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  Widget _desktopHeader(BuildContext context, List<ActivityModel> activities) {
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

  Widget _mobileHeader(BuildContext context, List<ActivityModel> activities) {
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
