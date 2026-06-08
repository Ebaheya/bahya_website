part of '../../../screens/patient_clinical_details.dart';

class _TabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.title,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        height: double.infinity,
        decoration: BoxDecoration(
          color: active
              ? Colors.pink[200]!.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active ? Border.all(color: Colors.pink) : null,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: active ? 1 : 0.55,
          child: Row(
            textDirection: _activeTextDirection,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customText(
                text: title,
                size: responsiveSize(context, 0.0085, min: 12, max: 15),
                color: const Color(0xFFE83E8C),
                bold: true,
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                color: const Color(0xFFE83E8C),
                size: responsiveSize(context, 0.013, min: 16, max: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswersTable extends StatelessWidget {
  final List<PatientAnswer> answers;

  const _AnswersTable({required this.answers});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.01, min: 12, max: 14),
              vertical: responsiveHeight(context, 0.014, min: 12, max: 14),
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              textDirection: _activeTextDirection,
              children: [
                SizedBox(
                  width: responsiveSize(context, 0.035, min: 40, max: 55),
                  child: customText(
                    text: '#',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: customText(
                    text: 'السؤال',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: customText(
                    text: 'الإجابة',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: const Color(0xFF271648),
                    bold: true,
                  ),
                ),
                SizedBox(
                  width: responsiveSize(context, 0.06, min: 80, max: 110),
                  child: customText(
                    text: 'الاسكور',
                    size: responsiveSize(context, 0.008, min: 12, max: 15),
                    color: textColor,
                    bold: true,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(answers.length, (index) {
            final item = answers[index];

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.01, min: 12, max: 14),
                vertical: responsiveHeight(context, 0.014, min: 11, max: 13),
              ),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : const Color(0xFFFFF8FC),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                textDirection: _activeTextDirection,
                children: [
                  SizedBox(
                    width: responsiveSize(context, 0.035, min: 40, max: 55),
                    child: customText(
                      text: '${index + 1}',
                      size: responsiveSize(context, 0.0075, min: 12, max: 14),
                      color: const Color(0xFF271648),
                      bold: true,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: customText(
                      text: item.question,
                      size: responsiveSize(context, 0.0075, min: 12, max: 14),
                      color: const Color(0xFF4B445C),
                      bold: true,
                      isCenter: false,
                      maxLines: 2,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: _activeCenterStart,
                      child: _AnswerBadge(answer: item.answer),
                    ),
                  ),
                  SizedBox(
                    width: responsiveSize(context, 0.06, min: 80, max: 110),
                    child: _ScoreBadge(score: item.score),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AnswerMobileCard extends StatelessWidget {
  final int index;
  final PatientAnswer item;

  const _AnswerMobileCard({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(responsiveSize(context, 0.012, min: 12, max: 16)),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFFF8FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF7D6E6)),
      ),
      child: Column(
        crossAxisAlignment: _activeCrossAxisStart,
        children: [
          customText(
            text: '${index + 1}. ${item.question}',
            size: responsiveSize(context, 0.008, min: 12, max: 15),
            color: const Color(0xFF271648),
            bold: true,
            isCenter: false,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            textDirection: _activeTextDirection,
            children: [
              _AnswerBadge(answer: item.answer),
              const SizedBox(width: 10),
              _ScoreBadge(score: item.score),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAssessmentsState extends StatelessWidget {
  const _EmptyAssessmentsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 18, max: 28),
        vertical: responsiveHeight(context, 0.055, min: 42, max: 68),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF7CFE0)),
      ),
      child: Column(
        children: [
          Container(
            width: responsiveSize(context, 0.05, min: 58, max: 74),
            height: responsiveSize(context, 0.05, min: 58, max: 74),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAF4),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF7CFE0)),
            ),
            child: Icon(
              Icons.assignment_late_outlined,
              color: const Color(0xFFE83E8C),
              size: responsiveSize(context, 0.024, min: 28, max: 36),
            ),
          ),
          SizedBox(height: responsiveHeight(context, 0.018, min: 14, max: 18)),
          customText(
            text: 'لا توجد تقييمات حتى الآن',
            size: responsiveSize(context, 0.011, min: 17, max: 22),
            color: const Color(0xFF271648),
            bold: true,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: customText(
              text:
                  'لم يقم هذا المريض بإرسال أي تقييمات بعد. ستظهر التقييمات هنا فور تسجيلها.',
              size: responsiveSize(context, 0.008, min: 12, max: 15),
              color: const Color(0xFF7A7890),
              bold: true,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentItem extends StatelessWidget {
  final PatientAssessment assessment;
  final bool isOpen;
  final VoidCallback onTap;

  const _AssessmentItem({
    required this.assessment,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isSmall = w < 700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.all(
          responsiveSize(context, 0.012, min: 14, max: 16),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF7D6E6)),
        ),
        child: isSmall
            ? Column(
                crossAxisAlignment: _activeCrossAxisStart,
                children: [
                  Row(
                    textDirection: _activeTextDirection,
                    children: [
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFFE83E8C),
                        size: responsiveSize(context, 0.018, min: 20, max: 28),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        color: const Color(0xFFE83E8C),
                        size: responsiveSize(context, 0.015, min: 18, max: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: customText(
                          text: assessment.formName,
                          size: responsiveSize(context, 0.01, min: 14, max: 18),
                          color: const Color(0xFF271648),
                          bold: true,
                          isCenter: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    textDirection: _activeTextDirection,
                    children: [
                      _AssessmentColumn(
                        title: 'تاريخ الإرسال',
                        value: assessment.submitDate,
                      ),
                      const SizedBox(width: 30),
                      _AssessmentColumn(
                        title: 'الاسكور',
                        value: assessment.score.toString(),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                textDirection: _activeTextDirection,
                children: [
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFE83E8C),
                    size: responsiveSize(context, 0.018, min: 20, max: 28),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    color: const Color(0xFFE83E8C),
                    size: responsiveSize(context, 0.015, min: 18, max: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: customText(
                      text: assessment.formName,
                      size: responsiveSize(context, 0.01, min: 14, max: 18),
                      color: const Color(0xFF271648),
                      bold: true,
                      isCenter: false,
                    ),
                  ),
                  _AssessmentColumn(
                    title: 'تاريخ الإرسال',
                    value: assessment.submitDate,
                  ),
                  const SizedBox(width: 40),
                  _AssessmentColumn(
                    title: 'الاسكور',
                    value: assessment.score.toString(),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _activeCenterStart,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.008, min: 11, max: 13),
          vertical: responsiveHeight(context, 0.007, min: 5, max: 7),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC9DAFF)),
        ),
        child: customText(
          text: score.toString(),
          size: responsiveSize(context, 0.007, min: 11, max: 13),
          color: const Color(0xFF3066BE),
          bold: true,
          isCenter: true,
        ),
      ),
    );
  }
}

class _AnswerBadge extends StatelessWidget {
  final String answer;

  const _AnswerBadge({required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.009, min: 12, max: 14),
        vertical: responsiveHeight(context, 0.007, min: 5, max: 7),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD98A)),
      ),
      child: customText(
        text: answer,
        size: responsiveSize(context, 0.007, min: 11, max: 13),
        color: const Color(0xFFE28A00),
        bold: true,
        isCenter: true,
      ),
    );
  }
}

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
