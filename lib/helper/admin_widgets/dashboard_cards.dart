import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double percentage;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = percentage >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Icon Box
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: getScreenWidth(context) * 0.02,
                ),
              ),

              /// Percentage
              customText(
                text:
                    "${percentage.toStringAsFixed(1)}% ${isPositive ? "+" : ""}",
                size: getScreenWidth(context) * 0.01,
                color: isPositive ? Colors.green : Colors.red,
                bold: true,
              ),
            ],
          ),

          SizedBox(height: getScreenHeight(context) * 0.01),

          /// Title
          customText(
            text: title,
            size: getScreenWidth(context) * 0.01,
            color: Colors.grey,
          ),
          SizedBox(height: getScreenHeight(context) * 0.01),

          /// Value
          customText(
            text: value,
            size: getScreenWidth(context) * 0.01,
            color: const Color(0xFF8B2C00),
            bold: true,
          ),
        ],
      ),
    );
  }
}
