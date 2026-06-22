part of '../../../screens/doctor/patient_clinical_details.dart';

class _HeaderButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: responsiveSize(context, 0.026, min: 34, max: 38),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            textDirection: _activeTextDirection,
            children: [
              Icon(
                icon,
                size: responsiveSize(context, 0.01, min: 15, max: 18),
                color: const Color(0xFFE83E8C),
              ),
              const SizedBox(width: 8),
              customText(
                text: title,
                size: responsiveSize(context, 0.0085, min: 12, max: 14),
                color: const Color(0xFFE83E8C),
                bold: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderInfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _HeaderInfoItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: _activeTextDirection,
      children: [
        Icon(
          icon,
          color: const Color(0xFFE83E8C),
          size: responsiveSize(context, 0.02, min: 22, max: 32),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: _activeCrossAxisStart,
          children: [
            customText(
              text: title,
              size: responsiveSize(context, 0.0075, min: 11, max: 14),
              color: const Color(0xFF7A7890),
              bold: true,
              isCenter: false,
            ),
            customText(
              text: value,
              size: responsiveSize(context, 0.008, min: 12, max: 15),
              color: textColor,
              bold: true,
              isCenter: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 18, max: 28),
      ),
      width: 2,
      height: responsiveHeight(context, 0.05, min: 38, max: 45),
      color: Colors.grey.shade200,
    );
  }
}

class _MoreInfoButton extends StatelessWidget {
  final bool opened;
  final VoidCallback onTap;

  const _MoreInfoButton({required this.opened, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: responsiveHeight(context, 0.05, min: 38, max: 42),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FC),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFF7CFE0)),
        ),
        child: Row(
          textDirection: _activeTextDirection,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              opened
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFFE83E8C),
              size: responsiveSize(context, 0.014, min: 18, max: 22),
            ),
            const SizedBox(width: 8),
            customText(
              text: 'المزيد من المعلومات',
              size: responsiveSize(context, 0.0075, min: 12, max: 14),
              color: const Color(0xFFE83E8C),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyInfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _EmergencyInfoItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: _activeTextDirection,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFFE83E8C),
          size: responsiveSize(context, 0.014, min: 18, max: 22),
        ),
        const SizedBox(width: 10),
        customText(
          text: '$title: ',
          size: responsiveSize(context, 0.0075, min: 12, max: 14),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(width: 6),
        customText(
          text: value,
          size: responsiveSize(context, 0.008, min: 12, max: 15),
          color: textColor,
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;

  const _SmallBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.008, min: 11, max: 13),
        vertical: responsiveHeight(context, 0.006, min: 4, max: 6),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: customText(
        text: text,
        size: responsiveSize(context, 0.0065, min: 11, max: 13),
        color: const Color(0xFFE83E8C),
        bold: true,
      ),
    );
  }
}
