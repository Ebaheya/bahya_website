part of 'volunteer_patients_widgets.dart';

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.index, required this.question});

  final int index;
  final Map<String, dynamic> question;

  String get questionId => question['id']?.toString() ?? '';
  String get questionText => question['text']?.toString() ?? '';
  String get type =>
      question['type']?.toString().toUpperCase() ?? 'SINGLE_SELECT';

  @override
  Widget build(BuildContext context) {
    final questionSize = responsiveHeight(context, 0.019, min: 15, max: 21);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.022, min: 16, max: 24),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.024, min: 16, max: 26)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.024, min: 18, max: 26),
        ),
        border: Border.all(color: const Color(0xFFF3D7EA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A004C).withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(context, 0.012, min: 8, max: 12),
                    vertical: responsiveHeight(context, 0.006, min: 4, max: 7),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE1F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: customText(
                    text: "${index + 1}".padLeft(2, "0"),
                    size: responsiveHeight(context, 0.015, min: 12, max: 15),
                    bold: true,
                    color: const Color(0xFF7A004C),
                  ),
                ),
                SizedBox(
                  width: responsiveSize(context, 0.012, min: 8, max: 12),
                ),
                Expanded(
                  child: customText(
                    text: "السؤال ${index + 1}: $questionText",
                    size: questionSize,
                    bold: true,
                    color: const Color(0xFF111827),
                    isCenter: false,
                    align: TextAlign.right,
                    maxLines: 3,
                  ),
                ),
              ],
            ),

            SizedBox(
              height: responsiveHeight(context, 0.018, min: 14, max: 22),
            ),

            if (type == 'SCALE')
              _ScaleAnswer(question: question)
            else
              ..._choiceWidgets(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _choiceWidgets(BuildContext context) {
    final choices = question['choices'] as List? ?? [];

    return choices.map<Widget>((choiceRaw) {
      final choice = Map<String, dynamic>.from(choiceRaw);
      return _ChoiceAnswer(
        questionId: questionId,
        choice: choice,
        isMulti: type == 'MULTI_SELECT',
      );
    }).toList();
  }
}

class _ChoiceAnswer extends StatelessWidget {
  const _ChoiceAnswer({
    required this.questionId,
    required this.choice,
    required this.isMulti,
  });

  final String questionId;
  final Map<String, dynamic> choice;
  final bool isMulti;

  @override
  Widget build(BuildContext context) {
    final choiceId = choice['id']?.toString() ?? '';
    final label = choice['label']?.toString() ?? '';

    final optionTextSize = responsiveHeight(context, 0.017, min: 13, max: 17);

    return BlocBuilder<VolunteerAssignmentsCubit, VolunteerAssignmentsState>(
      builder: (context, state) {
        final cubit = context.read<VolunteerAssignmentsCubit>();

        final selected = cubit.isChoiceSelected(
          questionId: questionId,
          choiceId: choiceId,
        );

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (isMulti) {
              cubit.toggleMultiChoiceAnswer(
                questionId: questionId,
                choiceId: choiceId,
              );
            } else {
              cubit.setSingleChoiceAnswer(
                questionId: questionId,
                choiceId: choiceId,
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(
              bottom: responsiveHeight(context, 0.01, min: 8, max: 12),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.016, min: 12, max: 16),
              vertical: responsiveHeight(context, 0.012, min: 10, max: 14),
            ),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xFFFFF1F8), Color(0xFFFFFBFD)],
                    )
                  : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFFFF7AB8)
                    : const Color(0xFFEAE7EF),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                isMulti
                    ? Checkbox(
                        value: selected,
                        activeColor: const Color(0xFFE40070),
                        onChanged: (_) {
                          cubit.toggleMultiChoiceAnswer(
                            questionId: questionId,
                            choiceId: choiceId,
                          );
                        },
                      )
                    : Radio<bool>(
                        value: true,
                        groupValue: selected,
                        activeColor: const Color(0xFFE40070),
                        onChanged: (_) {
                          cubit.setSingleChoiceAnswer(
                            questionId: questionId,
                            choiceId: choiceId,
                          );
                        },
                      ),
                Expanded(
                  child: customText(
                    text: label,
                    size: optionTextSize,
                    color: selected
                        ? const Color(0xFF7A004C)
                        : const Color(0xFF111827),
                    bold: selected,
                    isCenter: false,
                    align: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScaleAnswer extends StatelessWidget {
  const _ScaleAnswer({required this.question});

  final Map<String, dynamic> question;

  @override
  Widget build(BuildContext context) {
    final questionId = question['id']?.toString() ?? '';
    final min = int.tryParse(question['scaleMin']?.toString() ?? '') ?? 0;
    final max = int.tryParse(question['scaleMax']?.toString() ?? '') ?? 10;

    return BlocBuilder<VolunteerAssignmentsCubit, VolunteerAssignmentsState>(
      builder: (context, state) {
        final cubit = context.read<VolunteerAssignmentsCubit>();
        final selectedValue = cubit.getScaleAnswer(questionId);

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            for (int value = min; value <= max; value++)
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  cubit.setScaleAnswer(questionId: questionId, value: value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: responsiveSize(context, 0.045, min: 44, max: 58),
                  height: responsiveSize(context, 0.045, min: 44, max: 58),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: selectedValue == value
                        ? const LinearGradient(
                            colors: [Color(0xFFFF4D8D), Color(0xFFC0178B)],
                          )
                        : null,
                    color: selectedValue == value
                        ? null
                        : const Color(0xFFFFF0F8),
                    border: Border.all(
                      color: selectedValue == value
                          ? Colors.transparent
                          : const Color(0xFFFFC7DF),
                    ),
                  ),
                  child: customText(
                    text: '$value',
                    size: responsiveHeight(context, 0.016, min: 12, max: 16),
                    color: selectedValue == value
                        ? Colors.white
                        : const Color(0xFF7A004C),
                    bold: true,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
