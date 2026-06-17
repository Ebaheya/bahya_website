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
        height: responsiveHeight(context, 0.056, min: 46, max: 56),
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
