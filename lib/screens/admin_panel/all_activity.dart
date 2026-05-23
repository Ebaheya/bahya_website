import 'dart:ui';

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
  int selectedPage = 1;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: w * 0.72,
          padding: EdgeInsets.all(w * 0.028),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 35,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: w * 0.04,
                    height: w * 0.04,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(width: w * 0.015),

                  customText(
                    text: "Recent Activity",
                    size: w * 0.018,
                    color: const Color(0xFF272044),
                    bold: true,
                    isEnglish: true,
                  ),

                  const Spacer(),

                  SizedBox(width: w * 0.018),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              SizedBox(height: h * 0.035),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  filterChip(
                    context: context,
                    title: "All Activities",
                    icon: Icons.keyboard_arrow_down_rounded,
                  ),
                  SizedBox(width: w * 0.012),
                  filterChip(
                    context: context,
                    title: "Today",
                    icon: Icons.calendar_month_rounded,
                  ),
                ],
              ),

              SizedBox(height: h * 0.025),

              SizedBox(
                height: h * 0.45,
                child: ListView.builder(
                  itemCount: widget.activities.length,
                  itemBuilder: (context, index) {
                    final item = widget.activities[index];

                    return DialogActivityItem(
                      item: item,
                      showLine: index != widget.activities.length - 1,
                    );
                  },
                ),
              ),

              SizedBox(height: h * 0.02),

              Row(
                children: [
                  customText(
                    text: "Showing 5 of 24 activities",
                    size: w * 0.009,
                    color: Colors.grey[600],
                    isEnglish: true,
                  ),

                  const Spacer(),

                  pageButton(
                    context: context,
                    icon: Icons.arrow_back_ios_new_rounded,
                    selected: false,
                    onTap: () {},
                  ),
                  pageButton(
                    context: context,
                    text: "1",
                    selected: selectedPage == 1,
                    onTap: () => setState(() => selectedPage = 1),
                  ),
                  pageButton(
                    context: context,
                    text: "2",
                    selected: selectedPage == 2,
                    onTap: () => setState(() => selectedPage = 2),
                  ),
                  pageButton(
                    context: context,
                    text: "3",
                    selected: selectedPage == 3,
                    onTap: () => setState(() => selectedPage = 3),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: customText(
                      text: "...",
                      size: w * 0.009,
                      color: Colors.grey,
                      isEnglish: true,
                    ),
                  ),
                  pageButton(
                    context: context,
                    text: "5",
                    selected: selectedPage == 5,
                    onTap: () => setState(() => selectedPage = 5),
                  ),
                  pageButton(
                    context: context,
                    icon: Icons.arrow_forward_ios_rounded,
                    selected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterChip({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    final w = getScreenWidth(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          customText(
            text: title,
            size: w * 0.009,
            color: const Color(0xFF272044),
            isEnglish: true,
          ),
          SizedBox(width: w * 0.008),
          Icon(icon, color: const Color(0xFF272044), size: w * 0.012),
        ],
      ),
    );
  }

  Widget pageButton({
    required BuildContext context,
    String? text,
    IconData? icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final w = getScreenWidth(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: w * 0.028,
          height: w * 0.028,
          decoration: BoxDecoration(
            color: selected ? Colors.pink[50] : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? buttonColor.withOpacity(0.35)
                  : Colors.grey.withOpacity(0.14),
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, size: w * 0.009, color: Colors.grey[600])
                : customText(
                    text: text!,
                    size: w * 0.009,
                    color: selected ? buttonColor : Colors.grey[700],
                    bold: selected,
                    isEnglish: true,
                  ),
          ),
        ),
      ),
    );
  }
}

class DialogActivityItem extends StatelessWidget {
  final ActivityModel item;
  final bool showLine;

  const DialogActivityItem({
    super.key,
    required this.item,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 13,
                height: 13,
                margin: const EdgeInsets.only(top: 30),
                decoration: BoxDecoration(
                  color: item.dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: item.dotColor.withOpacity(0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Colors.grey.withOpacity(0.16),
                  ),
                ),
            ],
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: w * 0.012, bottom: h * 0.012),
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.025,
                vertical: h * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        customText(
                          text: item.title,
                          size: w * 0.011,
                          color: item.iconColor,
                          bold: true,
                          isEnglish: true,
                        ),
                        SizedBox(height: h * 0.008),
                        customText(
                          text: item.description,
                          size: w * 0.009,
                          color: Colors.grey[700],
                          isEnglish: true,
                        ),
                      ],
                    ),
                  ),

                  customText(
                    text: item.time,
                    size: w * 0.009,
                    color: Colors.grey[600],
                    isEnglish: true,
                  ),

                  SizedBox(width: w * 0.035),

                  Container(
                    width: w * 0.045,
                    height: w * 0.045,
                    decoration: BoxDecoration(
                      color: item.iconColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: w * 0.02,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final Color dotColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final bool showLine;

  const ActivityItem({
    super.key,
    required this.dotColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 7),
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: dotColor.withOpacity(0.35), blurRadius: 8),
                  ],
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: Colors.grey.withOpacity(0.18),
                  ),
                ),
            ],
          ),

          SizedBox(width: w * 0.014),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: h * 0.018),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: title,
                    size: w * 0.01,
                    bold: true,
                    color: textColor,
                    isEnglish: true,
                  ),
                  SizedBox(height: h * 0.006),
                  customText(
                    text: description,
                    size: w * 0.0085,
                    color: Colors.grey[600],
                    isEnglish: true,
                  ),
                  SizedBox(height: h * 0.006),
                  customText(
                    text: time,
                    size: w * 0.0075,
                    color: Colors.grey,
                    isEnglish: true,
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: w * 0.035,
            height: w * 0.035,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: w * 0.016),
          ),
        ],
      ),
    );
  }
}

class ActivityModel {
  final Color dotColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;
  final String time;

  ActivityModel({
    required this.dotColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
  });
}
