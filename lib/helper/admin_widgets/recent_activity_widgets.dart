import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

class ActivityModel {
  final Color dotColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;
  final String time;

  ActivityModel({
    required this.dotColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
  });
}

class DialogHeaderIcon extends StatelessWidget {
  const DialogHeaderIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.04, min: 46, max: 62);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.01, min: 12, max: 14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.25),
            blurRadius: responsiveSize(context, 0.012, min: 12, max: 16),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.history_rounded,
        color: Colors.white,
        size: responsiveSize(context, 0.018, min: 22, max: 28),
      ),
    );
  }
}

Widget activityFilterChip({
  required BuildContext context,
  required String title,
  required IconData icon,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
      vertical: responsiveHeight(context, 0.014, min: 9, max: 12),
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.01, min: 12, max: 14),
      ),
      border: Border.all(color: Colors.grey.withOpacity(0.14)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: responsiveSize(context, 0.008, min: 8, max: 10),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.009, min: 12, max: 15),
          color: const Color(0xFF272044),
          isEnglish: true,
        ),
        SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 12)),
        Icon(
          icon,
          color: const Color(0xFF272044),
          size: responsiveSize(context, 0.012, min: 16, max: 20),
        ),
      ],
    ),
  );
}

Widget activityPageButton({
  required BuildContext context,
  String? text,
  IconData? icon,
  required bool selected,
  required VoidCallback onTap,
}) {
  final size = responsiveSize(context, 0.028, min: 32, max: 42);

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: responsiveSize(context, 0.004, min: 3, max: 5),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.008, min: 8, max: 10),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: selected ? Colors.pink[50] : Colors.white,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.008, min: 8, max: 10),
          ),
          border: Border.all(
            color: selected
                ? buttonColor.withOpacity(0.35)
                : Colors.grey.withOpacity(0.14),
          ),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  size: responsiveSize(context, 0.009, min: 12, max: 15),
                  color: Colors.grey[600],
                )
              : customText(
                  text: text!,
                  size: responsiveSize(context, 0.009, min: 12, max: 15),
                  color: selected ? buttonColor : Colors.grey[700],
                  bold: selected,
                  isEnglish: true,
                ),
        ),
      ),
    ),
  );
}

class DialogActivityItem extends StatelessWidget {
  final ActivityModel item;
  final bool showLine;

  const DialogActivityItem({
    super.key,
    required this.item,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimelineDot(
            color: item.dotColor,
            showLine: showLine,
            topMargin: isMobile ? 24 : 30,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: responsiveSize(context, 0.012, min: 10, max: 16),
                bottom: responsiveHeight(context, 0.012, min: 10, max: 14),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.02, min: 14, max: 28),
                vertical: responsiveHeight(context, 0.02, min: 14, max: 22),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.014, min: 14, max: 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: responsiveSize(
                      context,
                      0.012,
                      min: 12,
                      max: 16,
                    ),
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: isMobile
                  ? _mobileActivityBody(context)
                  : _desktopActivityBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopActivityBody(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _activityTexts(context)),
        customText(
          text: item.time,
          size: responsiveSize(context, 0.009, min: 12, max: 15),
          color: Colors.grey[600],
          isEnglish: true,
          isCenter: false,
        ),
        SizedBox(width: responsiveSize(context, 0.035, min: 28, max: 50)),
        ActivityIcon(item: item),
      ],
    );
  }

  Widget _mobileActivityBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _activityTexts(context),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        Row(
          children: [
            ActivityIcon(item: item),
            const Spacer(),
            customText(
              text: item.time,
              size: responsiveSize(context, 0.0085, min: 11, max: 13),
              color: Colors.grey[600],
              isEnglish: true,
              isCenter: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _activityTexts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(
          text: item.title,
          size: responsiveSize(context, 0.011, min: 14, max: 18),
          color: item.iconColor,
          bold: true,
          isEnglish: true,
          isCenter: false,
          maxLines: 1,
        ),
        SizedBox(height: responsiveHeight(context, 0.008, min: 6, max: 9)),
        customText(
          text: item.description,
          size: responsiveSize(context, 0.009, min: 12, max: 15),
          color: Colors.grey[700],
          isEnglish: true,
          isCenter: false,
          maxLines: 2,
        ),
      ],
    );
  }
}

class ActivityItem extends StatelessWidget {
  final Color dotColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final bool showLine;

  const ActivityItem({
    super.key,
    required this.dotColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimelineDot(color: dotColor, showLine: showLine, topMargin: 7),
          SizedBox(width: responsiveSize(context, 0.014, min: 12, max: 20)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: responsiveHeight(context, 0.018, min: 12, max: 18),
              ),
              child: isMobile ? _mobileBody(context) : _desktopBody(context),
            ),
          ),
          if (!isMobile) ActivityIcon.fromValues(iconColor, icon),
        ],
      ),
    );
  }

  Widget _desktopBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.01, min: 14, max: 17),
          bold: true,
          color: textColor,
          isEnglish: true,
          isCenter: false,
          maxLines: 1,
        ),
        SizedBox(height: responsiveHeight(context, 0.006, min: 5, max: 7)),
        customText(
          text: description,
          size: responsiveSize(context, 0.0085, min: 12, max: 14),
          color: Colors.grey[600],
          isEnglish: true,
          isCenter: false,
          maxLines: 2,
        ),
        SizedBox(height: responsiveHeight(context, 0.006, min: 5, max: 7)),
        customText(
          text: time,
          size: responsiveSize(context, 0.0075, min: 11, max: 13),
          color: Colors.grey,
          isEnglish: true,
          isCenter: false,
        ),
      ],
    );
  }

  Widget _mobileBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.01, min: 14, max: 16),
          bold: true,
          color: textColor,
          isEnglish: true,
          isCenter: false,
          maxLines: 1,
        ),
        SizedBox(height: responsiveHeight(context, 0.006, min: 5, max: 7)),
        customText(
          text: description,
          size: responsiveSize(context, 0.0085, min: 12, max: 14),
          color: Colors.grey[600],
          isEnglish: true,
          isCenter: false,
          maxLines: 2,
        ),
        SizedBox(height: responsiveHeight(context, 0.01, min: 7, max: 10)),
        Row(
          children: [
            ActivityIcon.fromValues(iconColor, icon),
            const Spacer(),
            customText(
              text: time,
              size: responsiveSize(context, 0.0075, min: 11, max: 13),
              color: Colors.grey,
              isEnglish: true,
              isCenter: false,
            ),
          ],
        ),
      ],
    );
  }
}

class TimelineDot extends StatelessWidget {
  final Color color;
  final bool showLine;
  final double topMargin;

  const TimelineDot({
    super.key,
    required this.color,
    required this.showLine,
    required this.topMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: responsiveSize(context, 0.008, min: 10, max: 13),
          height: responsiveSize(context, 0.008, min: 10, max: 13),
          margin: EdgeInsets.only(top: topMargin),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: responsiveSize(context, 0.006, min: 6, max: 8),
              ),
            ],
          ),
        ),
        if (showLine)
          Expanded(
            child: Container(
              width: 1,
              margin: EdgeInsets.symmetric(
                vertical: responsiveHeight(context, 0.006, min: 5, max: 7),
              ),
              color: Colors.grey.withOpacity(0.18),
            ),
          ),
      ],
    );
  }
}

class ActivityIcon extends StatelessWidget {
  final Color iconColor;
  final IconData icon;

  ActivityIcon({super.key, required ActivityModel item})
    : iconColor = item.iconColor,
      icon = item.icon;

  const ActivityIcon.fromValues(this.iconColor, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.04, min: 38, max: 58);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 12, max: 16),
        ),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: responsiveSize(context, 0.018, min: 20, max: 28),
      ),
    );
  }
}
