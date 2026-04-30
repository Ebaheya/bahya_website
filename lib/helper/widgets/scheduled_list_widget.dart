import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ScheduledListWidget extends StatelessWidget {
  final List<Map<String, String>> scheduled = const [
    {
      "form": "PHQ-9",
      "date": "2025-10-25",
      "repeat": "يومي",
      "hour": "10:00 AM",
    },
    {
      "form": "GAD-7",
      "date": "2025-11-01",
      "repeat": "أسبوعي",
      "hour": "02:00 PM",
    },
    {
      "form": "BDI-II",
      "date": "2025-12-15",
      "repeat": "شهري",
      "hour": "09:00 AM",
    },
  ];

  const ScheduledListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Container(
      width: w * 0.9,
      padding: EdgeInsets.all(h * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        children: [
          customText(
            text: "النماذج المجدوَلة",
            size: h * 0.03,
            bold: true,
            color: const Color(0xFF7A004C),
          ),

          SizedBox(height: h * 0.02),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: h * 0.40,
              child: ListView.separated(
                itemCount: scheduled.length,
                separatorBuilder: (_, __) => SizedBox(height: h * 0.01),
                itemBuilder: (context, i) {
                  final item = scheduled[i];
                  return ScheduledItemCard(
                    formName: item["form"]!,
                    date: item["date"]!,
                    repeat: item["repeat"]!,
                    hour: item["hour"]!,
                    onDelete: () {
                      customDialog(
                        context: context,
                        title: "إلغاء الجدولة",
                        message:
                            "تم إلغاء جدولة النموذج ${item["form"]} بنجاح.",
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduledItemCard extends StatelessWidget {
  final String formName;
  final String date;
  final String repeat;
  final String hour;
  final VoidCallback onDelete;

  const ScheduledItemCard({
    super.key,
    required this.formName,
    required this.date,
    required this.repeat,
    required this.onDelete,
    required this.hour,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    return Container(
      width: w * 0.8,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4F4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: GestureDetector(
              onTap: onDelete,
              child: customText(
                text: "إلغاء",
                size: h * 0.018,
                color: Colors.red,
                bold: true,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              customText(
                text: formName,
                size: h * 0.02,
                color: const Color(0xFF7A004C),
                bold: true,
              ),
              customText(
                text: "$date - $hour",
                size: h * 0.017,
                color: const Color(0xFF7A004C),
                bold: true,
              ),
              customText(
                text: "($repeat)",
                size: h * 0.017,
                color: const Color(0xFF7A004C),
                bold: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
