part of '../../../screens/patient_clinical_details.dart';

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 10, max: 14),
        vertical: responsiveHeight(context, 0.007, min: 5, max: 8),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5F1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFFFC6DE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: _activeTextDirection,
        children: [
          customText(
            text: '$title: ',
            size: responsiveSize(context, 0.008, min: 11, max: 13),
            color: const Color(0xFFE83E8C),
            bold: true,
          ),
          customText(
            text: value,
            size: responsiveSize(context, 0.008, min: 11, max: 13),
            color: const Color(0xFF271648),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _AssessmentAnswersContent extends StatelessWidget {
  const _AssessmentAnswersContent({required this.assessment});

  final PatientAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final answers = assessment.answers;

    final isSmall = getScreenWidth(context) < 850;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF7CFE0)),
      ),
      child: Directionality(
        textDirection: _activeTextDirection,
        child: Column(
          crossAxisAlignment: _activeCrossAxisStart,
          children: [
            customText(
              text: 'تفاصيل التقييم',
              size: responsiveSize(context, 0.01, min: 15, max: 18),
              color: const Color(0xFFE83E8C),
              bold: true,
              isCenter: false,
            ),
            SizedBox(
              height: responsiveHeight(context, 0.018, min: 14, max: 18),
            ),
            _DoctorNoteCard(note: assessment.doctorNote),
            SizedBox(
              height: responsiveHeight(context, 0.018, min: 14, max: 18),
            ),
            if (isSmall)
              Column(
                children: List.generate(answers.length, (index) {
                  return _AnswerMobileCard(index: index, item: answers[index]);
                }),
              )
            else
              _AnswersTable(answers: answers),
          ],
        ),
      ),
    );
  }
}

class _DoctorNoteCard extends StatelessWidget {
  const _DoctorNoteCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final cleanNote = note.trim();
    final hasNote = cleanNote.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 12, max: 18)),
      decoration: BoxDecoration(
        color: hasNote ? const Color(0xFFFFF4FA) : const Color(0xFFF8F8FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasNote ? const Color(0xFFF7CFE0) : const Color(0xFFE7E7EC),
        ),
      ),
      child: Directionality(
        textDirection: _activeTextDirection,
        child: Column(
          crossAxisAlignment: _activeCrossAxisStart,
          children: [
            Row(
              textDirection: _activeTextDirection,
              children: [
                Container(
                  width: responsiveSize(context, 0.032, min: 34, max: 42),
                  height: responsiveSize(context, 0.032, min: 34, max: 42),
                  decoration: BoxDecoration(
                    color: hasNote
                        ? const Color(0xFFFFE5F1)
                        : Colors.grey.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    color: hasNote ? const Color(0xFFE83E8C) : Colors.grey,
                    size: responsiveSize(context, 0.016, min: 19, max: 24),
                  ),
                ),
                SizedBox(width: responsiveSize(context, 0.01, min: 8, max: 12)),
                Expanded(
                  child: customText(
                    text: 'ملاحظات الدكتور',
                    size: responsiveSize(context, 0.0095, min: 14, max: 17),
                    color: const Color(0xFF271648),
                    bold: true,
                    isCenter: false,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
            customText(
              text: hasNote ? cleanNote : 'لا توجد ملاحظات مسجلة من الدكتور.',
              size: responsiveSize(context, 0.0085, min: 12, max: 15),
              color: hasNote
                  ? const Color(0xFF4B445C)
                  : const Color(0xFF8B8796),
              bold: true,
              isCenter: false,
              maxLines: 6,
            ),
          ],
        ),
      ),
    );
  }
}

String getAnswerText(
  Map<String, dynamic> answer,
  Map<String, dynamic> question,
) {
  final choiceIds =
      (answer['choiceIds'] as List?)?.map((e) => e.toString()).toList() ?? [];

  final choices =
      (question['choices'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  final labels = choices
      .where((c) => choiceIds.contains(c['id']))
      .map((c) => c['label'].toString())
      .toList();

  return labels.isEmpty ? '-' : labels.join(', ');
}

int getAnswerScore(Map<String, dynamic> answer, Map<String, dynamic> question) {
  final choiceIds =
      (answer['choiceIds'] as List?)?.map((e) => e.toString()).toList() ?? [];

  final choices =
      (question['choices'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  return choices
      .where((c) => choiceIds.contains(c['id']))
      .fold<int>(0, (sum, c) => sum + ((c['score'] as num?)?.toInt() ?? 0));
}
