import 'package:bahya_website/helper/admin_widgets/recent%20activity/recent_activity_widgets.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class RecentActivityDialog extends StatefulWidget {
  final List<ActivityModel> activities;

  const RecentActivityDialog({super.key, required this.activities});

  @override
  State<RecentActivityDialog> createState() => _RecentActivityDialogState();
}

class _RecentActivityDialogState extends State<RecentActivityDialog> {
  int currentPage = 0;
  static const int pageSize = 5;

  int get totalPages {
    if (widget.activities.isEmpty) return 1;
    return (widget.activities.length / pageSize).ceil();
  }

  List<ActivityModel> get currentItems {
    final start = currentPage * pageSize;
    final end = (start + pageSize) > widget.activities.length
        ? widget.activities.length
        : start + pageSize;

    if (start >= widget.activities.length) return [];
    return widget.activities.sublist(start, end);
  }

  void nextPage() {
    if (currentPage >= totalPages - 1) return;
    setState(() => currentPage++);
  }

  void previousPage() {
    if (currentPage <= 0) return;
    setState(() => currentPage--);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isMobile
              ? MediaQuery.sizeOf(context).width * 0.92
              : responsiveSize(context, 0.52, min: 620, max: 820),
          height: isMobile
              ? MediaQuery.sizeOf(context).height * 0.78
              : MediaQuery.sizeOf(context).height * 0.76,
          padding: EdgeInsets.all(
            responsiveSize(context, 0.018, min: 18, max: 28),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 20, max: 28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: responsiveSize(context, 0.04, min: 42, max: 58),
                    height: responsiveSize(context, 0.04, min: 42, max: 58),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: responsiveSize(context, 0.012, min: 12, max: 18),
                  ),
                  Expanded(
                    child: customText(
                      text: "Recent Activity",
                      size: responsiveSize(context, 0.014, min: 18, max: 24),
                      color: const Color(0xFF272044),
                      bold: true,
                      isEnglish: true,
                      isCenter: false,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(
                height: responsiveHeight(context, 0.026, min: 18, max: 28),
              ),
              Expanded(
                child: currentItems.isEmpty
                    ? const Center(child: Text("No recent activity available"))
                    : ListView.builder(
                        itemCount: currentItems.length,
                        itemBuilder: (context, index) {
                          final item = currentItems[index];

                          return ActivityItem(
                            dotColor: item.dotColor,
                            iconColor: item.iconColor,
                            icon: item.icon,
                            title: item.title,
                            description: item.description,
                            time: item.time,
                            showLine: index != currentItems.length - 1,
                          );
                        },
                      ),
              ),
              SizedBox(
                height: responsiveHeight(context, 0.02, min: 14, max: 22),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage == 0 ? null : previousPage,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: customText(
                      text: "${currentPage + 1} / $totalPages",
                      size: responsiveSize(context, 0.01, min: 13, max: 16),
                      color: const Color(0xFF272044),
                      bold: true,
                      isEnglish: true,
                    ),
                  ),
                  IconButton(
                    onPressed: currentPage >= totalPages - 1 ? null : nextPage,
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
