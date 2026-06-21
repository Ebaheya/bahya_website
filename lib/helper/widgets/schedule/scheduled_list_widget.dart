import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
part 'scheduled_item_card.dart';
part 'scheduled_item_components.dart';

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
    setState(() => widget.scheduled[index].isDeleting = true);
  }

  void deleteScheduledAfterAnimation(int index) {
    if (index < 0 || index >= widget.scheduled.length) return;

    final removedItem = widget.scheduled[index];

    setState(() => widget.scheduled.removeAt(index));

    customDialog(
      context: context,
      title: "إلغاء الجدولة",
      message: "تم إلغاء جدولة النموذج ${removedItem.form} بنجاح.",
      isSuccess: true,
    );
  }

  List<ScheduledItemModel> _groupPublishedAssignments(
    List<ScheduledItemModel> items,
  ) {
    final Map<String, ScheduledItemModel> grouped = {};

    for (final item in items) {
      final key = [
        item.form,
        item.date,
        item.hour,
        item.repeat,
        item.publishType,
      ].join('|');

      if (!grouped.containsKey(key)) {
        grouped[key] = ScheduledItemModel(
          form: item.form,
          date: item.date,
          repeat: item.repeat,
          hour: item.hour,
          publishType: item.publishType,
          patientNames: [...item.patientNames],
          volunteerNames: [...item.volunteerNames],
          isDeleting: item.isDeleting,
        );
      } else {
        final old = grouped[key]!;

        grouped[key] = ScheduledItemModel(
          form: old.form,
          date: old.date,
          repeat: old.repeat,
          hour: old.hour,
          publishType: old.publishType,
          patientNames: {...old.patientNames, ...item.patientNames}.toList(),
          volunteerNames: {
            ...old.volunteerNames,
            ...item.volunteerNames,
          }.toList(),
          isDeleting: old.isDeleting,
        );
      }
    }

    return grouped.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;
    final groupedPublishedAssignments = _groupPublishedAssignments(
      widget.publishedAssignments,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: isMobile ? double.infinity : getScreenWidth(context) * 0.9,
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.035, min: 16, max: 46),
          vertical: responsiveHeight(context, 0.045, min: 22, max: 46),
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .97),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 20, max: 26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: responsiveSize(context, 0.025, min: 18, max: 30),
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            if (widget.scheduled.isNotEmpty) ...[
              _SectionTitle(title: "النماذج المجدولة"),
              SizedBox(
                height: responsiveHeight(context, 0.04, min: 22, max: 40),
              ),
              _CardsList(
                items: widget.scheduled,
                showDelete: true,
                onDelete: removeScheduled,
                onAnimationEnd: deleteScheduledAfterAnimation,
              ),
              SizedBox(
                height: responsiveHeight(context, 0.05, min: 28, max: 50),
              ),
            ],
            const _SectionTitle(title: "النماذج المنشورة"),
            SizedBox(height: responsiveHeight(context, 0.04, min: 22, max: 40)),
            if (widget.isLoadingAssignments)
              customLoading()
            else if (groupedPublishedAssignments.isEmpty)
              customText(
                text: "لا توجد نماذج منشورة حالياً",
                size: responsiveSize(context, 0.011, min: 14, max: 20),
                color: Colors.grey.shade600,
                bold: true,
              )
            else
              _CardsList(
                items: groupedPublishedAssignments,
                showDelete: false,
                onDelete: (_) {},
                onAnimationEnd: (_) {},
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.022, min: 22, max: 34),
          bold: true,
          color: const Color(0xFF8A0057),
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
        Container(
          width: responsiveSize(context, 0.05, min: 55, max: 75),
          height: responsiveHeight(context, 0.006, min: 3, max: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFC2187A),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}

class _CardsList extends StatelessWidget {
  final List<ScheduledItemModel> items;
  final bool showDelete;
  final void Function(int index) onDelete;
  final void Function(int index) onAnimationEnd;

  const _CardsList({
    required this.items,
    required this.showDelete,
    required this.onDelete,
    required this.onAnimationEnd,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 20)),
      itemBuilder: (context, index) {
        final item = items[index];

        final card = ScheduledItemCard(
          formName: item.form,
          date: item.date,
          repeat: item.repeat,
          hour: item.hour,
          publishType: item.publishType,
          patientNames: item.patientNames,
          volunteerNames: item.volunteerNames,
          onDelete: () => onDelete(index),
          showDelete: showDelete,
        );

        if (!showDelete || !item.isDeleting) return card;

        return AnimatedScheduleRemove(
          onAnimationEnd: () => onAnimationEnd(index),
          child: card,
        );
      },
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
