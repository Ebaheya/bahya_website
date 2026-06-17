import 'package:bahya_website/helper/filter_dropdown.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
part 'reports_card_widgets.dart';

class ReportDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> report;
  final ValueChanged<String> onStatusChanged;

  const ReportDetailsDialog({
    super.key,
    required this.report,
    required this.onStatusChanged,
  });

  @override
  State<ReportDetailsDialog> createState() => _ReportDetailsDialogState();
}

class _ReportDetailsDialogState extends State<ReportDetailsDialog> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.report["status"].toString();
  }

  void saveStatus() {
    widget.onStatusChanged(selectedStatus);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isMobile = w < 650;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.03, min: 12, max: 40),
        vertical: responsiveHeight(context, 0.03, min: 16, max: 36),
      ),
      child: Container(
        width: isMobile ? w * 0.94 : (w * 0.45).clamp(520.0, 720.0),
        padding: EdgeInsets.all(
          responsiveSize(context, 0.018, min: 16, max: 28),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.018, min: 20, max: 30),
          ),
          border: Border.all(color: const Color(0xFFFFC6DD)),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.18),
              blurRadius: responsiveSize(context, 0.02, min: 24, max: 36),
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogHeader(report: widget.report),
                SizedBox(
                  height: responsiveHeight(context, 0.025, min: 18, max: 28),
                ),
                Wrap(
                  spacing: responsiveSize(context, 0.012, min: 12, max: 18),
                  runSpacing: responsiveHeight(
                    context,
                    0.014,
                    min: 12,
                    max: 16,
                  ),
                  children: [
                    _ReportInfoBox(
                      title: "Reporter",
                      value: widget.report["reporter"].toString(),
                      icon: Icons.person_outline,
                    ),
                    _ReportInfoBox(
                      title: "Email",
                      value: widget.report["email"].toString(),
                      icon: Icons.email_outlined,
                    ),
                    _ReportInfoBox(
                      title: "Role",
                      value: widget.report["role"].toString(),
                      icon: Icons.admin_panel_settings_outlined,
                    ),
                    _ReportInfoBox(
                      title: "Date",
                      value: widget.report["date"].toString(),
                      icon: Icons.calendar_month_outlined,
                    ),
                  ],
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.025, min: 18, max: 28),
                ),
                customText(
                  text: "Problem Body",
                  size: responsiveSize(context, 0.009, min: 14, max: 17),
                  color: const Color(0xFF7A004C),
                  bold: true,
                  isEnglish: true,
                  isCenter: false,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.01, min: 8, max: 12),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(
                    responsiveSize(context, 0.012, min: 14, max: 18),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFC6DD)),
                  ),
                  child: customText(
                    text: widget.report["body"].toString(),
                    size: responsiveSize(context, 0.008, min: 13, max: 16),
                    color: Colors.black87,
                    isEnglish: true,
                    isCenter: false,
                    maxLines: isMobile ? 10 : 6,
                  ),
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.025, min: 18, max: 28),
                ),
                customText(
                  text: "Change Status",
                  size: responsiveSize(context, 0.009, min: 14, max: 17),
                  color: const Color(0xFF7A004C),
                  bold: true,
                  isEnglish: true,
                  isCenter: false,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.01, min: 8, max: 12),
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.065, min: 48, max: 58),
                  child: FilterDropdown(
                    hint: selectedStatus,
                    items: const ["Pending", "Investigating", "Completed"],
                    onChanged: (v) {
                      setState(() => selectedStatus = v);
                    },
                  ),
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.03, min: 22, max: 32),
                ),
                isMobile
                    ? Column(
                        children: [
                          DialogActionButton(
                            title: "Save Status",
                            icon: Icons.check_rounded,
                            isPrimary: true,
                            onTap: saveStatus,
                          ),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.012,
                              min: 10,
                              max: 14,
                            ),
                          ),
                          DialogActionButton(
                            title: "Cancel",
                            icon: Icons.close_rounded,
                            isPrimary: false,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: DialogActionButton(
                              title: "Cancel",
                              icon: Icons.close_rounded,
                              isPrimary: false,
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(
                            width: responsiveSize(
                              context,
                              0.008,
                              min: 10,
                              max: 14,
                            ),
                          ),
                          Expanded(
                            child: DialogActionButton(
                              title: "Save Status",
                              icon: Icons.check_rounded,
                              isPrimary: true,
                              onTap: saveStatus,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final Map<String, dynamic> report;

  const _DialogHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: responsiveSize(context, 0.045, min: 50, max: 70),
          height: responsiveSize(context, 0.045, min: 50, max: 70),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.report_problem_rounded,
            color: Colors.white,
            size: responsiveSize(context, 0.02, min: 26, max: 34),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.014, min: 12, max: 22)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                text: report["title"].toString(),
                size: responsiveSize(context, 0.012, min: 17, max: 24),
                color: textColor,
                bold: true,
                isEnglish: true,
                isCenter: false,
                maxLines: 2,
              ),
              SizedBox(
                height: responsiveHeight(context, 0.006, min: 4, max: 7),
              ),
              customText(
                text: "Report Details",
                size: responsiveSize(context, 0.008, min: 12, max: 15),
                color: Colors.grey,
                bold: true,
                isEnglish: true,
                isCenter: false,
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: responsiveSize(context, 0.028, min: 36, max: 44),
            height: responsiveSize(context, 0.028, min: 36, max: 44),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4FA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFC6DD)),
            ),
            child: Icon(
              Icons.close_rounded,
              color: const Color(0xFFE83E8C),
              size: responsiveSize(context, 0.014, min: 18, max: 22),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReportInfoBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Container(
      width: w < 900 ? double.infinity : 250,
      padding: EdgeInsets.all(responsiveSize(context, 0.01, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFC6DD)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE83E8C),
            size: responsiveSize(context, 0.014, min: 18, max: 22),
          ),
          SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customText(
                  text: title,
                  size: responsiveSize(context, 0.007, min: 11, max: 13),
                  color: Colors.grey,
                  isEnglish: true,
                  isCenter: false,
                ),
                customText(
                  text: value,
                  size: responsiveSize(context, 0.008, min: 12, max: 15),
                  color: textColor,
                  bold: true,
                  isEnglish: true,
                  isCenter: false,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
