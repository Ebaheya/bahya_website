import 'package:bahya_website/bloc/cubit/publish_schedule_cubit.dart';
import 'package:bahya_website/data/api/models/form_model.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  void removeScheduled(ScheduledItemModel item, int index) {
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

  bool _canCancelAssignment(ScheduledItemModel item) {
    final status = item.repeat.trim().toUpperCase();

    return status != "CANCELLED" &&
        status != "SUBMITTED" &&
        status != "REVIEWED";
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
          id: item.id,
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
          id: old.id,
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
              const _SectionTitle(title: "النماذج المجدولة"),
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
                showDelete: true,
                canShowDelete: _canCancelAssignment,
                onDelete: (item, _) {
                  context
                      .read<PublishScheduleCubit>()
                      .cancelPublishedAssignment(item.id);
                },
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

class _CardsList extends StatefulWidget {
  final List<ScheduledItemModel> items;
  final bool showDelete;
  final bool Function(ScheduledItemModel item)? canShowDelete;
  final void Function(ScheduledItemModel item, int index) onDelete;
  final void Function(int index) onAnimationEnd;

  const _CardsList({
    required this.items,
    required this.showDelete,
    required this.onDelete,
    required this.onAnimationEnd,
    this.canShowDelete,
  });

  @override
  State<_CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<_CardsList>
    with SingleTickerProviderStateMixin {
  static const int _itemsPerPage = 2;

  late final AnimationController _controller;
  int _currentPage = 0;

  int get _totalPages {
    if (widget.items.isEmpty) return 1;
    return (widget.items.length / _itemsPerPage).ceil();
  }

  List<ScheduledItemModel> get _currentItems {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, widget.items.length);
    return widget.items.sublist(start, end);
  }

  int get _startIndex => _currentPage * _itemsPerPage;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _CardsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    final lastValidPage = (_totalPages - 1).clamp(0, _totalPages);

    if (_currentPage > lastValidPage) {
      _currentPage = lastValidPage;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changePage(int page) {
    if (page < 0 || page >= _totalPages || page == _currentPage) return;

    setState(() => _currentPage = page);

    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentItems = _currentItems;

    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: Column(
            key: ValueKey(_currentPage),
            children: List.generate(currentItems.length, (index) {
              final item = currentItems[index];
              final originalIndex = _startIndex + index;

              final shouldShowDelete =
                  widget.showDelete &&
                  (widget.canShowDelete == null || widget.canShowDelete!(item));

              final animation = CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  (index * 0.20).clamp(0.0, 0.70),
                  1,
                  curve: Curves.easeOutCubic,
                ),
              );

              final card = FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.16),
                    end: Offset.zero,
                  ).animate(animation),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: index == currentItems.length - 1
                          ? 0
                          : responsiveHeight(context, 0.018, min: 14, max: 20),
                    ),
                    child: ScheduledItemCard(
                      formName: item.form,
                      date: item.date,
                      repeat: item.repeat,
                      hour: item.hour,
                      publishType: item.publishType,
                      patientNames: item.patientNames,
                      volunteerNames: item.volunteerNames,
                      onDelete: () => widget.onDelete(item, originalIndex),
                      showDelete: shouldShowDelete,
                    ),
                  ),
                ),
              );

              if (!widget.showDelete || !item.isDeleting) return card;

              return AnimatedScheduleRemove(
                onAnimationEnd: () => widget.onAnimationEnd(originalIndex),
                child: card,
              );
            }),
          ),
        ),
        if (_totalPages > 1) ...[
          SizedBox(height: responsiveHeight(context, 0.028, min: 18, max: 28)),
          _SchedulePaginationBar(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: _changePage,
          ),
        ],
      ],
    );
  }
}

class _SchedulePaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _SchedulePaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return Center(
      child: Container(
        padding: EdgeInsets.all(responsiveSize(context, 0.006, min: 6, max: 9)),
        decoration: BoxDecoration(
          color: const Color(0xFFFEFBFD),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.018, min: 20, max: 24),
          ),
          border: Border.all(
            color: const Color(0xFFE7549B).withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF831843).withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PageIconButton(
              icon: Icons.chevron_left_rounded,
              enabled: currentPage > 0,
              onTap: () => onPageChanged(currentPage - 1),
            ),
            SizedBox(width: isMobile ? 4 : 6),
            ...List.generate(totalPages, (index) {
              final selected = index == currentPage;

              return InkWell(
                onTap: () => onPageChanged(index),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 3 : 4),
                  width: selected
                      ? responsiveSize(context, 0.038, min: 38, max: 44)
                      : responsiveSize(context, 0.034, min: 34, max: 38),
                  height: responsiveSize(context, 0.034, min: 34, max: 38),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: selected ? null : const Color(0xFFF8EEF6),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFE7549B,
                              ).withValues(alpha: 0.24),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: customText(
                    text: '${index + 1}',
                    size: responsiveSize(context, 0.010, min: 13, max: 15),
                    color: selected ? Colors.white : const Color(0xFF831843),
                    bold: true,
                  ),
                ),
              );
            }),
            SizedBox(width: isMobile ? 4 : 6),
            _PageIconButton(
              icon: Icons.chevron_right_rounded,
              enabled: currentPage < totalPages - 1,
              onTap: () => onPageChanged(currentPage + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: responsiveSize(context, 0.034, min: 34, max: 38),
        height: responsiveSize(context, 0.034, min: 34, max: 38),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFE7549B).withValues(alpha: 0.10)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFFE7549B) : Colors.grey,
          size: responsiveSize(context, 0.018, min: 20, max: 24),
        ),
      ),
    );
  }
}

class ScheduledItemModel {
  final String id;
  final String form;
  final String date;
  final String repeat;
  final String hour;
  final String publishType;
  final List<String> patientNames;
  final List<String> volunteerNames;
  bool isDeleting;

  ScheduledItemModel({
    required this.id,
    required this.form,
    required this.date,
    required this.repeat,
    required this.hour,
    required this.publishType,
    required this.patientNames,
    required this.volunteerNames,
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
