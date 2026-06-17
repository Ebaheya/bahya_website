part of '../../../screens/patients_info.dart';

class _PatientCardProfile extends StatelessWidget {
  final String patientName;
  final String fileNumber;
  final String diseaseStatus;
  final String registerDate;

  const _PatientCardProfile({
    required this.patientName,
    required this.fileNumber,
    required this.diseaseStatus,
    required this.registerDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: responsiveSize(context, 0.035, min: 38, max: 52),
          backgroundColor: const Color(0xFFFFE4F1),
          child: CircleAvatar(
            radius: responsiveSize(context, 0.029, min: 30, max: 42),
            backgroundColor: const Color(0xFFE83E8C),
            child: customText(
              text: patientName.isNotEmpty ? patientName[0] : 'م',
              size: responsiveSize(context, 0.018, min: 22, max: 30),
              color: Colors.white,
              bold: true,
            ),
          ),
        ),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
        customText(
          text: patientName,
          size: responsiveSize(context, 0.011, min: 16, max: 22),
          color: const Color(0xFF271648),
          bold: true,
          maxLines: 1,
        ),
        const SizedBox(height: 6),
        customText(
          text: fileNumber,
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          color: const Color(0xFFE83E8C),
          bold: true,
          isEnglish: true,
        ),
        SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
        _StatusBadge(status: diseaseStatus),
        const Spacer(),
        Container(height: 1, color: const Color(0xFFFFC6DD)),
        SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: responsiveSize(context, 0.012, min: 15, max: 20),
              color: const Color(0xFFE83E8C),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                customText(
                  text: registerDate,
                  size: responsiveSize(context, 0.0075, min: 12, max: 14),
                  color: const Color(0xFF271648),
                  bold: true,
                  isEnglish: true,
                ),
                customText(
                  text: 'تاريخ التسجيل',
                  size: responsiveSize(context, 0.0068, min: 11, max: 13),
                  color: const Color(0xFF7A7890),
                  bold: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PatientInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PatientInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = _activeTextDirection == TextDirection.ltr;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.008, min: 10, max: 12),
        vertical: responsiveHeight(context, 0.012, min: 8, max: 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF1E6EE)),
      ),
      child: Row(
        textDirection: _activeTextDirection,
        children: [
          CircleAvatar(
            radius: responsiveSize(context, 0.012, min: 16, max: 18),
            backgroundColor: const Color(0xFFFFEAF4),
            child: Icon(
              icon,
              size: responsiveSize(context, 0.011, min: 14, max: 18),
              color: const Color(0xFFE83E8C),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: _activeCrossAxisStart,
              children: [
                customText(
                  text: '$label:',
                  size: responsiveSize(context, 0.0075, min: 12, max: 14),
                  color: const Color(0xFF6B667A),
                  bold: true,
                  isCenter: false,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                customText(
                  text: value,
                  size: responsiveSize(context, 0.008, min: 12, max: 15),
                  color: const Color(0xFF271648),
                  bold: true,
                  isCenter: false,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: responsiveSize(context, 0.004, min: 5, max: 7),
            height: responsiveHeight(context, 0.05, min: 34, max: 45),
            decoration: BoxDecoration(
              color: const Color(0xFFE83E8C),
              borderRadius: BorderRadius.only(
                topLeft: isEnglish ? Radius.zero : const Radius.circular(10),
                bottomLeft: isEnglish ? Radius.zero : const Radius.circular(10),
                topRight: isEnglish ? const Radius.circular(10) : Radius.zero,
                bottomRight: isEnglish
                    ? const Radius.circular(10)
                    : Radius.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isEnglish = _activeTextDirection == TextDirection.ltr;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.009, min: 12, max: 14),
        vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAF4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        children: isEnglish
            ? [
                _statusDot(),
                const SizedBox(width: 7),
                customText(
                  text: 'الحالة: ${_translateStatus(status)}',
                  size: responsiveSize(context, 0.0075, min: 11, max: 13),
                  color: const Color(0xFFE83E8C),
                  bold: true,
                ),
              ]
            : [
                customText(
                  text: 'الحالة: ${_translateStatus(status)}',
                  size: responsiveSize(context, 0.0075, min: 11, max: 13),
                  color: const Color(0xFFE83E8C),
                  bold: true,
                ),
                const SizedBox(width: 7),
                _statusDot(),
              ],
      ),
    );
  }

  Widget _statusDot() {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFFE83E8C),
        shape: BoxShape.circle,
      ),
    );
  }
}

String _translateStatus(String status) {
  switch (status) {
    case 'Active treatment':
      return 'تحت علاج نشط';
    case 'Follow-up':
      return 'متابعة دورية';
    case 'Newly diagnosed':
      return 'حديث التشخيص';
    case 'Recurrence':
      return 'انتكاس';
    case 'Metastatic':
      return 'منتشر';
    default:
      return status;
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  final int? badgeCount;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: responsiveSize(context, 0.028, min: 38, max: 44),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.011, min: 14, max: 17),
        ),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFE83E8C) : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isPrimary ? const Color(0xFFE83E8C) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: responsiveSize(context, 0.01, min: 16, max: 18),
              color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
            ),
            const SizedBox(width: 8),
            customText(
              text: title,
              size: responsiveSize(context, 0.0075, min: 12, max: 13),
              color: isPrimary ? Colors.white : const Color(0xFF6B667A),
              bold: true,
              isCenter: false,
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: const Color(0xFFE83E8C),
                child: customText(
                  text: badgeCount.toString(),
                  size: 11,
                  color: Colors.white,
                  bold: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppBarActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarActionButton({
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
            children: [
              Icon(
                icon,
                size: responsiveSize(context, 0.01, min: 15, max: 18),
                color: textColor,
              ),
              const SizedBox(width: 8),
              customText(
                text: title,
                size: responsiveSize(context, 0.0085, min: 12, max: 14),
                color: textColor,
                bold: true,
                isCenter: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
