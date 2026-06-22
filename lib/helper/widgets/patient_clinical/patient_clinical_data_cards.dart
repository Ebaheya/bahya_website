part of '../../../screens/doctor/patient_clinical_details.dart';

class _AssessmentColumn extends StatelessWidget {
  final String title;
  final String value;

  const _AssessmentColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: _activeCrossAxisStart,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.0075, min: 11, max: 14),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(height: 5),
        customText(
          text: value,
          size: responsiveSize(context, 0.008, min: 12, max: 15),
          color: const Color(0xFFE83E8C),
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

class _ClinicalCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_DataRowItem> rows;

  const _ClinicalCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: responsiveHeight(context, 0.35, min: 260, max: 330),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
              vertical: responsiveHeight(context, 0.018, min: 12, max: 16),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              textDirection: _activeTextDirection,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFE83E8C),
                  size: responsiveSize(context, 0.015, min: 18, max: 24),
                ),
                const SizedBox(width: 8),
                customText(
                  text: title,
                  size: responsiveSize(context, 0.01, min: 14, max: 18),
                  color: const Color(0xFFE83E8C),
                  bold: true,
                  isCenter: false,
                ),
              ],
            ),
          ),
          ...rows.map((row) => _ClinicalRow(row: row)),
        ],
      ),
    );
  }
}

class _ClinicalRow extends StatelessWidget {
  final _DataRowItem row;

  const _ClinicalRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isSmall = w < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
        vertical: responsiveHeight(context, 0.016, min: 11, max: 14),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: isSmall
          ? Column(
              crossAxisAlignment: _activeCrossAxisStart,
              children: [
                customText(
                  text: row.label,
                  size: responsiveSize(context, 0.0075, min: 12, max: 14),
                  color: const Color(0xFF6B667A),
                  bold: true,
                  isCenter: false,
                ),
                const SizedBox(height: 7),
                row.badgeType == null
                    ? customText(
                        text: row.value,
                        size: responsiveSize(context, 0.007, min: 12, max: 14),
                        color: const Color(0xFF271648),
                        bold: true,
                        isCenter: false,
                        maxLines: 2,
                      )
                    : _ValueBadge(text: row.value, type: row.badgeType!),
              ],
            )
          : Row(
              textDirection: _activeTextDirection,
              children: [
                Expanded(
                  child: customText(
                    text: row.label,
                    size: responsiveSize(context, 0.0075, min: 12, max: 14),
                    color: const Color(0xFF6B667A),
                    bold: true,
                    isCenter: false,
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: _activeCenterEnd,
                    child: row.badgeType == null
                        ? customText(
                            text: row.value,
                            size: responsiveSize(
                              context,
                              0.007,
                              min: 12,
                              max: 14,
                            ),
                            color: const Color(0xFF271648),
                            bold: true,
                            isCenter: false,
                            maxLines: 2,
                          )
                        : _ValueBadge(text: row.value, type: row.badgeType!),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const _ValueBadge({required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;

    switch (type) {
      case BadgeType.success:
        bg = const Color(0xFFE7F8EE);
        border = const Color(0xFFB7E6C8);
        textColor = const Color(0xFF178A46);
        break;
      case BadgeType.warning:
        bg = const Color(0xFFFFF4DA);
        border = const Color(0xFFFFD98A);
        textColor = const Color(0xFFE28A00);
        break;
      case BadgeType.danger:
        bg = const Color(0xFFFFE9E9);
        border = const Color(0xFFFFB7B7);
        textColor = const Color(0xFFE53935);
        break;
      case BadgeType.info:
        bg = const Color(0xFFEAF1FF);
        border = const Color(0xFFC9DAFF);
        textColor = const Color(0xFF3066BE);
        break;
      case BadgeType.status:
        bg = const Color(0xFFE7F8EE);
        border = const Color(0xFFB7E6C8);
        textColor = const Color(0xFF178A46);
        break;
      case BadgeType.neutral:
        bg = const Color(0xFFF1F1F3);
        border = const Color(0xFFD9D9DE);
        textColor = const Color(0xFF555A66);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.008, min: 10, max: 12),
        vertical: responsiveHeight(context, 0.007, min: 5, max: 7),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: customText(
        text: text,
        size: responsiveSize(context, 0.007, min: 11, max: 13),
        color: textColor,
        bold: true,
        isCenter: true,
        maxLines: 1,
      ),
    );
  }
}

class _DrugsCard extends StatelessWidget {
  final List<String> drugs;

  const _DrugsCard({required this.drugs});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: responsiveHeight(context, 0.35, min: 260, max: 330),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
              vertical: responsiveHeight(context, 0.018, min: 12, max: 16),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              textDirection: _activeTextDirection,
              children: [
                Icon(
                  Icons.medication_outlined,
                  color: const Color(0xFFE83E8C),
                  size: responsiveSize(context, 0.015, min: 18, max: 24),
                ),
                const SizedBox(width: 8),
                customText(
                  text: 'الأدوية',
                  size: responsiveSize(context, 0.01, min: 14, max: 18),
                  color: const Color(0xFFE83E8C),
                  bold: true,
                  isCenter: false,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.012, min: 14, max: 18),
            ),
            child: Column(
              crossAxisAlignment: _activeCrossAxisStart,
              children: drugs.map((drug) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    textDirection: _activeTextDirection,
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFFE83E8C),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: customText(
                          text: drug,
                          size: responsiveSize(
                            context,
                            0.007,
                            min: 12,
                            max: 14,
                          ),
                          color: const Color(0xFF271648),
                          bold: true,
                          isCenter: false,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: _activeCrossAxisStart,
      children: [
        customText(
          text: title,
          size: responsiveSize(context, 0.015, min: 20, max: 28),
          color: const Color(0xFF271648),
          bold: true,
          isCenter: false,
        ),
        const SizedBox(height: 6),
        customText(
          text: subtitle,
          size: responsiveSize(context, 0.008, min: 12, max: 15),
          color: const Color(0xFF7A7890),
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}
