import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ScheduledListWidget extends StatefulWidget {
  const ScheduledListWidget({super.key});

  @override
  State<ScheduledListWidget> createState() => _ScheduledListWidgetState();
}

class _ScheduledListWidgetState extends State<ScheduledListWidget> {
  final List<ScheduledItemModel> scheduled = [
    ScheduledItemModel(
      form: "PHQ-9",
      date: "الأحد، 25 مايو 2025",
      repeat: "يومي",
      hour: "09:30 AM",
    ),
    ScheduledItemModel(
      form: "GAD-7",
      date: "كل يوم أحد",
      repeat: "أسبوعي",
      hour: "02:00 PM",
    ),
    ScheduledItemModel(
      form: "BDI-II",
      date: "1 يونيو 2025",
      repeat: "شهري",
      hour: "12:00 AM",
    ),
  ];

  void removeScheduled(int index) {
    setState(() {
      scheduled[index].isDeleting = true;
    });
  }

  void deleteScheduledAfterAnimation(int index) {
    if (index < 0 || index >= scheduled.length) return;

    final removedItem = scheduled[index];

    setState(() {
      scheduled.removeAt(index);
    });

    customDialog(
      context: context,
      title: "إلغاء الجدولة",
      message: "تم إلغاء جدولة النموذج ${removedItem.form} بنجاح.",
      isSuccess: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: w * 0.9,
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.035,
          vertical: h * 0.045,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.97),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            customText(
              text: "النماذج المجدولة",
              size: h * 0.04,
              bold: true,
              color: const Color(0xFF8A0057),
            ),
            SizedBox(height: h * 0.012),
            Container(
              width: 70,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFC2187A),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(height: h * 0.04),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scheduled.length,
              separatorBuilder: (_, __) => SizedBox(height: h * 0.018),
              itemBuilder: (context, index) {
                final item = scheduled[index];

                return item.isDeleting
                    ? AnimatedScheduleRemove(
                        onAnimationEnd: () =>
                            deleteScheduledAfterAnimation(index),
                        child: ScheduledItemCard(
                          formName: item.form,
                          date: item.date,
                          repeat: item.repeat,
                          hour: item.hour,
                          onDelete: () {},
                        ),
                      )
                    : ScheduledItemCard(
                        formName: item.form,
                        date: item.date,
                        repeat: item.repeat,
                        hour: item.hour,
                        onDelete: () => removeScheduled(index),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduledItemModel {
  final String form;
  final String date;
  final String repeat;
  final String hour;
  bool isDeleting;

  ScheduledItemModel({
    required this.form,
    required this.date,
    required this.repeat,
    required this.hour,
    this.isDeleting = false,
  });
}

class AnimatedScheduleRemove extends StatefulWidget {
  const AnimatedScheduleRemove({
    super.key,
    required this.child,
    required this.onAnimationEnd,
  });

  final Widget child;
  final VoidCallback onAnimationEnd;

  @override
  State<AnimatedScheduleRemove> createState() => _AnimatedScheduleRemoveState();
}

class _AnimatedScheduleRemoveState extends State<AnimatedScheduleRemove>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> fadeAnimation;
  late final Animation<double> sizeAnimation;
  late final Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    sizeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.04, 0),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward().whenComplete(widget.onAnimationEnd);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: sizeAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: slideAnimation, child: widget.child),
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
    required this.hour,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: w * 0.028, vertical: h * 0.022),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3DCEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: h * 0.09,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7AA8),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(width: w * 0.025),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.014,
              vertical: h * 0.01,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: customText(
              text: "نشط",
              size: h * 0.018,
              bold: true,
              color: const Color(0xFFE5005F),
            ),
          ),
          SizedBox(width: w * 0.05),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: formName,
                  size: h * 0.027,
                  bold: true,
                  color: const Color(0xFF8A0057),
                ),
                SizedBox(height: h * 0.006),
                customText(
                  text: repeat,
                  size: h * 0.019,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.025,
                vertical: h * 0.014,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ScheduleInfoBlock(
                      title: "الموعد القادم",
                      value: date,
                      subValue: "($repeat)",
                    ),
                  ),
                  Container(
                    width: 1,
                    height: h * 0.065,
                    color: const Color(0xFFEED5E3),
                  ),
                  Expanded(
                    child: ScheduleInfoBlock(
                      title: "وقت النشر",
                      value: hour,
                      isTime: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: w * 0.025),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.014,
                vertical: h * 0.01,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFBCD4)),
              ),
              child: customText(
                text: "إلغاء",
                size: h * 0.017,
                bold: true,
                color: const Color(0xFFE5005F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleInfoBlock extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final bool isTime;

  const ScheduleInfoBlock({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        customText(
          text: title,
          size: h * 0.018,
          color: Colors.grey.shade600,
          bold: true,
        ),
        SizedBox(height: h * 0.007),
        customText(
          text: value,
          size: isTime ? h * 0.032 : h * 0.018,
          bold: true,
          color: isTime ? const Color(0xFF8A0057) : const Color(0xFF333333),
        ),
        if (subValue != null) ...[
          SizedBox(height: h * 0.003),
          customText(
            text: subValue!,
            size: h * 0.017,
            bold: true,
            color: const Color(0xFFE5005F),
          ),
        ],
      ],
    );
  }
}
