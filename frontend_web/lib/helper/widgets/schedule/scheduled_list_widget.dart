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
          color: Colors.white.withOpacity(.97),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.024, min: 20, max: 26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
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

  bool get isAllPatients {
    return publishType == "كل المرضى" ||
        publishType == "ALL_PATIENTS" ||
        publishType.contains("كل");
  }

  bool get isVolunteerTarget {
    return publishType == "متطوع لمريض" ||
        publishType == "المتطوعين" ||
        publishType == "VOLUNTEER_FOR_PATIENT";
  }

  bool get isSelectedPatients {
    return publishType == "مجموعه من المرضى" ||
        publishType == "مجموعة من المرضى" ||
        publishType == "SELECTED_PATIENTS";
  }

  String get readablePublishType {
    if (isAllPatients) return "كل المرضى";
    if (isVolunteerTarget) return "متطوعين ومرضى";
    if (isSelectedPatients) return "مجموعة من المرضى";
    return publishType;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 750;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.022, min: 14, max: 34),
        vertical: responsiveHeight(context, 0.022, min: 14, max: 24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.018, min: 16, max: 20),
        ),
        border: Border.all(color: const Color(0xFFF3DCEB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: responsiveSize(context, 0.016, min: 12, max: 18),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isMobile ? _mobileLayout(context) : _desktopLayout(context),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _SideLine(),
        SizedBox(width: responsiveSize(context, 0.018, min: 14, max: 26)),
        _StatusBadge(showDelete: showDelete),
        SizedBox(width: responsiveSize(context, 0.026, min: 18, max: 36)),
        Expanded(flex: 4, child: _MainInfo()),
        SizedBox(width: responsiveSize(context, 0.02, min: 14, max: 26)),
        Expanded(flex: 4, child: _DateInfoBox()),
        if (showDelete) ...[
          SizedBox(width: responsiveSize(context, 0.02, min: 14, max: 24)),
          _CancelButton(onDelete: onDelete),
        ],
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SideLine(
              height: responsiveHeight(context, 0.055, min: 42, max: 56),
            ),
            SizedBox(width: responsiveSize(context, 0.012, min: 10, max: 14)),
            _StatusBadge(showDelete: showDelete),
            const Spacer(),
            if (showDelete) _CancelButton(onDelete: onDelete),
          ],
        ),
        SizedBox(height: responsiveHeight(context, 0.018, min: 12, max: 18)),
        _MainInfo(),
        SizedBox(height: responsiveHeight(context, 0.018, min: 12, max: 18)),
        _DateInfoBox(),
      ],
    );
  }

  Widget _MainInfo() {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customText(
              text: formName,
              size: responsiveSize(context, 0.014, min: 17, max: 26),
              bold: true,
              color: const Color(0xFF8A0057),
              maxLines: 2,
              isCenter: false,
            ),
            SizedBox(height: responsiveHeight(context, 0.01, min: 8, max: 12)),
            _TargetBadge(text: readablePublishType),
            SizedBox(
              height: responsiveHeight(context, 0.014, min: 10, max: 14),
            ),
            if (isAllPatients)
              const _NamesBlock(
                title: "المرضى",
                names: ["كل المرضى"],
                icon: Icons.groups_rounded,
              )
            else if (isVolunteerTarget) ...[
              _NamesBlock(
                title: "المرضى المختارين",
                names: patientNames,
                icon: Icons.personal_injury_rounded,
              ),
              SizedBox(
                height: responsiveHeight(context, 0.012, min: 8, max: 12),
              ),
              _NamesBlock(
                title: "المتطوعين المختارين",
                names: volunteerNames,
                icon: Icons.volunteer_activism_rounded,
              ),
            ] else
              _NamesBlock(
                title: "المرضى المختارين",
                names: patientNames,
                icon: Icons.personal_injury_rounded,
              ),
          ],
        );
      },
    );
  }

  Widget _DateInfoBox() {
    return Builder(
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.02, min: 14, max: 28),
            vertical: responsiveHeight(context, 0.014, min: 12, max: 16),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4FA),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 14, max: 16),
            ),
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
                height: responsiveHeight(context, 0.065, min: 46, max: 65),
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
        );
      },
    );
  }
}

class _NamesBlock extends StatelessWidget {
  final String title;
  final List<String> names;
  final IconData icon;

  const _NamesBlock({
    required this.title,
    required this.names,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final shownNames = names.isEmpty ? ["غير محدد"] : names;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.01, min: 10, max: 14)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8FC),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 12, max: 14),
        ),
        border: Border.all(color: const Color(0xFFF3DCEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFE5007D),
                size: responsiveSize(context, 0.012, min: 16, max: 20),
              ),
              SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 8)),
              customText(
                text: title,
                size: responsiveSize(context, 0.0085, min: 12, max: 15),
                bold: true,
                color: const Color(0xFF7B1FA2),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.01, min: 8, max: 10)),
          Wrap(
            spacing: responsiveSize(context, 0.008, min: 8, max: 10),
            runSpacing: responsiveHeight(context, 0.008, min: 6, max: 8),
            children: shownNames.map((name) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsiveSize(context, 0.01, min: 10, max: 12),
                  vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFBCD4)),
                ),
                child: customText(
                  text: name,
                  size: responsiveSize(context, 0.008, min: 11, max: 14),
                  bold: true,
                  color: const Color(0xFF8A0057),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SideLine extends StatelessWidget {
  final double? height;

  const _SideLine({this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsiveSize(context, 0.004, min: 5, max: 6),
      height: height ?? responsiveHeight(context, 0.13, min: 95, max: 135),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7AA8),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool showDelete;

  const _StatusBadge({required this.showDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 12, max: 16),
        vertical: responsiveHeight(context, 0.01, min: 8, max: 10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4F0),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 16),
        ),
      ),
      child: customText(
        text: showDelete ? "مجدول" : "منشور",
        size: responsiveSize(context, 0.009, min: 12, max: 16),
        bold: true,
        color: const Color(0xFFE5005F),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _CancelButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDelete,
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.012, min: 12, max: 14),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.012, min: 12, max: 16),
          vertical: responsiveHeight(context, 0.01, min: 8, max: 10),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEF4),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.012, min: 12, max: 14),
          ),
          border: Border.all(color: const Color(0xFFFFBCD4)),
        ),
        child: customText(
          text: "إلغاء",
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          bold: true,
          color: const Color(0xFFE5005F),
        ),
      ),
    );
  }
}

class _TargetBadge extends StatelessWidget {
  const _TargetBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.01, min: 10, max: 12),
        vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E8FF),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 12, max: 14),
        ),
        border: Border.all(color: const Color(0xFFE1BEE7)),
      ),
      child: customText(
        text: text,
        size: responsiveSize(context, 0.0085, min: 12, max: 15),
        bold: true,
        color: const Color(0xFF7B1FA2),
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
    return Column(
      children: [
        Icon(
          isTime ? Icons.access_time_rounded : Icons.calendar_month_rounded,
          color: const Color(0xFFE5007D),
          size: responsiveSize(context, 0.016, min: 20, max: 26),
        ),
        SizedBox(height: responsiveHeight(context, 0.008, min: 6, max: 8)),
        customText(
          text: title,
          size: responsiveSize(context, 0.008, min: 11, max: 14),
          bold: true,
          color: Colors.grey.shade600,
          maxLines: 1,
        ),
        SizedBox(height: responsiveHeight(context, 0.006, min: 4, max: 6)),
        customText(
          text: value,
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          bold: true,
          color: const Color(0xFF8A0057),
          maxLines: 2,
        ),
        if (subValue != null) ...[
          SizedBox(height: responsiveHeight(context, 0.004, min: 3, max: 5)),
          customText(
            text: subValue!,
            size: responsiveSize(context, 0.0075, min: 10, max: 13),
            color: Colors.grey.shade500,
            maxLines: 1,
          ),
        ],
      ],
    );
  }
}
