import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

import 'recent_activity_widgets.dart';

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
    final isMobile = w < 650;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isMobile ? w * 0.94 : (w * 0.72).clamp(720.0, 1050.0),
          constraints: BoxConstraints(maxHeight: h * 0.88),
          padding: EdgeInsets.all(
            responsiveSize(context, 0.022, min: 18, max: 34),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 22, max: 28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: responsiveSize(context, 0.026, min: 24, max: 35),
                offset: Offset(
                  0,
                  responsiveHeight(context, 0.02, min: 12, max: 18),
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isMobile ? _mobileHeader(context) : _desktopHeader(context),
              SizedBox(
                height: responsiveHeight(context, 0.03, min: 20, max: 34),
              ),
              isMobile ? _mobileFilters(context) : _desktopFilters(context),
              SizedBox(
                height: responsiveHeight(context, 0.025, min: 18, max: 25),
              ),
              SizedBox(
                height: isMobile
                    ? (h * 0.48).clamp(320.0, 460.0)
                    : (h * 0.45).clamp(330.0, 520.0),
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
              SizedBox(
                height: responsiveHeight(context, 0.02, min: 14, max: 22),
              ),
              isMobile
                  ? _mobilePagination(context)
                  : _desktopPagination(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _desktopHeader(BuildContext context) {
    return Row(
      children: [
        const DialogHeaderIcon(),
        SizedBox(width: responsiveSize(context, 0.015, min: 16, max: 24)),
        customText(
          text: "Recent Activity",
          size: responsiveSize(context, 0.018, min: 24, max: 34),
          color: const Color(0xFF272044),
          bold: true,
          isEnglish: true,
          isCenter: false,
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            size: responsiveSize(context, 0.016, min: 20, max: 26),
          ),
        ),
      ],
    );
  }

  Widget _mobileHeader(BuildContext context) {
    return Row(
      children: [
        const DialogHeaderIcon(),
        SizedBox(width: responsiveSize(context, 0.012, min: 12, max: 16)),
        Expanded(
          child: customText(
            text: "Recent Activity",
            size: responsiveSize(context, 0.016, min: 22, max: 28),
            color: const Color(0xFF272044),
            bold: true,
            isEnglish: true,
            isCenter: false,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            size: responsiveSize(context, 0.016, min: 20, max: 24),
          ),
        ),
      ],
    );
  }

  Widget _desktopFilters(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        activityFilterChip(
          context: context,
          title: "All Activities",
          icon: Icons.keyboard_arrow_down_rounded,
        ),
        SizedBox(width: responsiveSize(context, 0.012, min: 12, max: 18)),
        activityFilterChip(
          context: context,
          title: "Today",
          icon: Icons.calendar_month_rounded,
        ),
      ],
    );
  }

  Widget _mobileFilters(BuildContext context) {
    return Wrap(
      spacing: responsiveSize(context, 0.01, min: 10, max: 14),
      runSpacing: responsiveHeight(context, 0.012, min: 8, max: 12),
      alignment: WrapAlignment.end,
      children: [
        activityFilterChip(
          context: context,
          title: "All Activities",
          icon: Icons.keyboard_arrow_down_rounded,
        ),
        activityFilterChip(
          context: context,
          title: "Today",
          icon: Icons.calendar_month_rounded,
        ),
      ],
    );
  }

  Widget _desktopPagination(BuildContext context) {
    return Row(
      children: [
        customText(
          text: "Showing 5 of 24 activities",
          size: responsiveSize(context, 0.009, min: 12, max: 15),
          color: Colors.grey[600],
          isEnglish: true,
        ),
        const Spacer(),
        _paginationButtons(context),
      ],
    );
  }

  Widget _mobilePagination(BuildContext context) {
    return Column(
      children: [
        customText(
          text: "Showing 5 of 24 activities",
          size: responsiveSize(context, 0.009, min: 12, max: 14),
          color: Colors.grey[600],
          isEnglish: true,
        ),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _paginationButtons(context),
        ),
      ],
    );
  }

  Widget _paginationButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        activityPageButton(
          context: context,
          icon: Icons.arrow_back_ios_new_rounded,
          selected: false,
          onTap: () {},
        ),
        activityPageButton(
          context: context,
          text: "1",
          selected: selectedPage == 1,
          onTap: () => setState(() => selectedPage = 1),
        ),
        activityPageButton(
          context: context,
          text: "2",
          selected: selectedPage == 2,
          onTap: () => setState(() => selectedPage = 2),
        ),
        activityPageButton(
          context: context,
          text: "3",
          selected: selectedPage == 3,
          onTap: () => setState(() => selectedPage = 3),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.006, min: 6, max: 8),
          ),
          child: customText(
            text: "...",
            size: responsiveSize(context, 0.009, min: 12, max: 15),
            color: Colors.grey,
            isEnglish: true,
          ),
        ),
        activityPageButton(
          context: context,
          text: "5",
          selected: selectedPage == 5,
          onTap: () => setState(() => selectedPage = 5),
        ),
        activityPageButton(
          context: context,
          icon: Icons.arrow_forward_ios_rounded,
          selected: false,
          onTap: () {},
        ),
      ],
    );
  }
}
