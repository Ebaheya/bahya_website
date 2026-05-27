import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ScheduledListWidget extends StatefulWidget {
  const ScheduledListWidget({
    super.key,
    required this.scheduled,
    required this.publishedForms,
    this.publishedAssignments = const [],
    this.isLoadingAssignments = false,
  });

  final List<ScheduledItemModel> scheduled;
  final List<FormModel> publishedForms;
  final List<ScheduledItemModel> publishedAssignments;
  final bool isLoadingAssignments;

  @override
  State<ScheduledListWidget> createState() => _ScheduledListWidgetState();
}

class _ScheduledListWidgetState extends State<ScheduledListWidget> {
  void removeScheduled(int index) {
    setState(() {
      widget.scheduled[index].isDeleting = true;
    });
  }

  void deleteScheduledAfterAnimation(int index) {
    if (index < 0 || index >= widget.scheduled.length) return;

    final removedItem = widget.scheduled[index];

    setState(() {
      widget.scheduled.removeAt(index);
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
            if (widget.scheduled.isNotEmpty) ...[
              customText(
                text: "النماذج المجدولة",
                size: h * 0.04,
                bold: true,
                color: const Color(0xFF8A0057),
              ),
              SizedBox(height: h * 0.012),
              _sectionLine(),
              SizedBox(height: h * 0.04),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.scheduled.length,
                separatorBuilder: (_, __) => SizedBox(height: h * 0.018),
                itemBuilder: (context, index) {
                  final item = widget.scheduled[index];

                  final card = ScheduledItemCard(
                    formName: item.form,
                    date: item.date,
                    repeat: item.repeat,
                    hour: item.hour,
                    publishType: item.publishType,
                    patientNames: item.patientNames,
                    volunteerNames: item.volunteerNames,
                    onDelete: () => removeScheduled(index),
                  );

                  return item.isDeleting
                      ? AnimatedScheduleRemove(
                          onAnimationEnd: () =>
                              deleteScheduledAfterAnimation(index),
                          child: ScheduledItemCard(
                            formName: item.form,
                            date: item.date,
                            repeat: item.repeat,
                            hour: item.hour,
                            publishType: item.publishType,
                            patientNames: item.patientNames,
                            volunteerNames: item.volunteerNames,
                            onDelete: () {},
                          ),
                        )
                      : card;
                },
              ),
              SizedBox(height: h * 0.05),
            ],
            customText(
              text: "النماذج المنشورة",
              size: h * 0.04,
              bold: true,
              color: const Color(0xFF8A0057),
            ),
            SizedBox(height: h * 0.012),
            _sectionLine(),
            SizedBox(height: h * 0.04),
            if (widget.isLoadingAssignments)
              customLoading()
            else if (widget.publishedAssignments.isEmpty)
              customText(
                text: "لا توجد نماذج منشورة حالياً",
                size: h * 0.02,
                color: Colors.grey.shade600,
                bold: true,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.publishedAssignments.length,
                separatorBuilder: (_, __) => SizedBox(height: h * 0.018),
                itemBuilder: (context, index) {
                  final item = widget.publishedAssignments[index];

                  return ScheduledItemCard(
                    formName: item.form,
                    date: item.date,
                    repeat: item.repeat,
                    hour: item.hour,
                    publishType: item.publishType,
                    patientNames: item.patientNames,
                    volunteerNames: item.volunteerNames,
                    onDelete: () {},
                    showDelete: false,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLine() {
    return Container(
      width: 70,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFC2187A),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class ScheduledItemModel {
  final String form;
  final String date;
  final String repeat;
  final String hour;
  final String publishType;
  final List<String> patientNames;
  final List<String> volunteerNames;
  bool isDeleting;

  ScheduledItemModel({
    required this.form,
    required this.date,
    required this.repeat,
    required this.hour,
    required this.publishType,
    this.patientNames = const [],
    this.volunteerNames = const [],
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
  final String publishType;
  final List<String> patientNames;
  final List<String> volunteerNames;
  final VoidCallback onDelete;
  final bool showDelete;

  const ScheduledItemCard({
    super.key,
    required this.formName,
    required this.date,
    required this.repeat,
    required this.hour,
    required this.publishType,
    required this.patientNames,
    required this.volunteerNames,
    required this.onDelete,
    this.showDelete = true,
  });

  String get targetText {
    if (publishType == "كل المرضى") return "موجه لكل المرضى";

    if (publishType == "مريض واحد") {
      final patient = patientNames.isEmpty
          ? "غير محدد"
          : patientNames.join("، ");

      return "موجه للمريض: $patient";
    }

    if (publishType == "متطوع لمريض" || publishType == "المتطوعين") {
      final patients = patientNames.isEmpty
          ? "غير محدد"
          : patientNames.join("، ");
      final volunteers = volunteerNames.isEmpty
          ? "غير محدد"
          : volunteerNames.join("، ");

      return "المريض: $patients\nالمتطوع: $volunteers";
    }

    return "نوع النشر غير محدد";
  }

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: h * 0.13,
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
              text: showDelete ? "مجدول" : "منشور",
              size: h * 0.018,
              bold: true,
              color: const Color(0xFFE5005F),
            ),
          ),
          SizedBox(width: w * 0.04),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: formName,
                  size: h * 0.026,
                  bold: true,
                  color: const Color(0xFF8A0057),
                ),
                SizedBox(height: h * 0.008),
                _TargetBadge(text: publishType),
                SizedBox(height: h * 0.01),
                customText(
                  text: targetText,
                  size: h * 0.017,
                  color: Colors.grey.shade700,
                  bold: true,
                ),
              ],
            ),
          ),
          SizedBox(width: w * 0.025),
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
                      title: showDelete ? "الموعد القادم" : "تاريخ النشر",
                      value: date,
                      subValue: showDelete ? "($repeat)" : null,
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
                      value: hour.isEmpty ? "-" : hour,
                      isTime: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showDelete) ...[
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
        ],
      ),
    );
  }
}

class _TargetBadge extends StatelessWidget {
  const _TargetBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E8FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1BEE7)),
      ),
      child: customText(
        text: text,
        size: h * 0.016,
        bold: true,
        color: const Color(0xFF7B1FA2),
      ),
    );
  }
}


