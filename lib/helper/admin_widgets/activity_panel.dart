import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customText(
            text: "Recent Activity",
            size: getScreenHeight(context) * 0.025,
            color: textColor,
            bold: true,
            isEnglish: true,
          ),
          SizedBox(height: 10),
          ActivityItem(
            dotColor: Colors.blue,
            title: "Dr. Sarah Johnson",
            description: "Updated patient record",
            time: "2 minutes ago",
          ),
          ActivityItem(
            dotColor: Colors.red,
            title: "Dr. Mohammed",
            description: "Failed to upload document",
            time: "32 minutes ago",
          ),
          ActivityItem(
            dotColor: Colors.grey,
            title: "Dr. Ahmed Johnson",
            description: "Modified system settings",
            time: "42 minutes ago",
          ),
        ],
      ),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final Color dotColor;
  final String title;
  final String description;
  final String time;

  const ActivityItem({
    super.key,
    required this.dotColor,
    required this.title,
    required this.description,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// dot
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            /// text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// title
                  customText(
                    text: title,
                    size: getScreenHeight(context) * 0.02,
                    bold: true,
                    color: textColor,
                    isEnglish: true,
                  ),

                  const SizedBox(height: 4),

                  /// description
                  customText(
                    text: description,
                    size: getScreenHeight(context) * 0.017,
                    bold: false,
                    color: Colors.grey,
                    isEnglish: true,
                  ),

                  const SizedBox(height: 4),

                  /// time
                  customText(
                    text: time,
                    size: getScreenHeight(context) * 0.015,
                    bold: false,
                    color: Colors.grey,
                    isEnglish: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
