part of 'scheduled_list_widget.dart';

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
