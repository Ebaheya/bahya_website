part of 'saved_filler_widget.dart';

extension _SavedFillerFields on _DynamicFormFillerWidgetState {
  Widget _questionCard({required int index, required dynamic question}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.022, min: 14, max: 22),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.024, min: 14, max: 22)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6FB),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.022, min: 16, max: 22),
        ),
        border: Border.all(color: const Color(0xFFFFD6E9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE40070).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(
            text: "السؤال ${index + 1}: ${question.text ?? ""}",
            size: responsiveHeight(context, 0.02, min: 14, max: 19),
            bold: true,
            color: const Color(0xFF7A004C),
          ),
          SizedBox(height: responsiveHeight(context, 0.018, min: 12, max: 18)),
          if (question.type == "SCALE")
            _scaleQuestion(question)
          else
            ..._choiceQuestion(question),
        ],
      ),
    );
  }

  Widget _scaleQuestion(dynamic question) {
    final cubit = context.read<DoctorFormsCubit>();

    final min = question.scaleMin ?? 0;
    final max = question.scaleMax ?? 10;
    final current = cubit.getScaleAnswer(question.id) ?? min;

    return Column(
      children: [
        Slider(
          value: current.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: const Color(0xFFE40070),
          inactiveColor: const Color(0xFFFFC7DF),
          label: current.toString(),
          onChanged: (value) {
            final score = value.round();

            cubit.setScaleAnswer(
              questionId: question.id,
              value: score,
              score: score,
            );
            _updateState(() {});
          },
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.02, min: 14, max: 18),
            vertical: responsiveHeight(context, 0.008, min: 6, max: 8),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEAF5),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.016, min: 12, max: 14),
            ),
          ),
          child: Text(
            current.toString(),
            style: TextStyle(
              color: const Color(0xFF7A004C),
              fontWeight: FontWeight.bold,
              fontSize: responsiveHeight(context, 0.02, min: 15, max: 18),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _choiceQuestion(dynamic question) {
    final cubit = context.read<DoctorFormsCubit>();

    return (question.choices ?? []).map<Widget>((choice) {
      final selected = cubit.isChoiceSelected(
        questionId: question.id,
        choiceId: choice.id,
      );

      final score = choice.score ?? choice.value ?? 0;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(
          bottom: responsiveHeight(context, 0.012, min: 8, max: 12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.016, min: 10, max: 14),
          vertical: responsiveHeight(context, 0.012, min: 8, max: 12),
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFEAF5) : Colors.white,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.018, min: 12, max: 16),
          ),
          border: Border.all(
            color: selected ? const Color(0xFFE40070) : const Color(0xFFFFD6E9),
          ),
        ),
        child: _isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _choiceMainRow(question, choice, selected, score),
                  SizedBox(
                    height: responsiveHeight(context, 0.008, min: 6, max: 8),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _scoreBadge(score),
                  ),
                ],
              )
            : Row(
                children: [
                  _scoreBadge(score),
                  const Spacer(),
                  _choiceMainRow(question, choice, selected, score),
                ],
              ),
      );
    }).toList();
  }

  Widget _choiceMainRow(
    dynamic question,
    dynamic choice,
    bool selected,
    dynamic score,
  ) {
    final cubit = context.read<DoctorFormsCubit>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        question.type == "MULTI_SELECT"
            ? Checkbox(
                value: selected,
                activeColor: const Color(0xFF7A004C),
                onChanged: (_) {
                  cubit.toggleMultiChoiceAnswer(
                    questionId: question.id,
                    choiceId: choice.id,
                    score: score,
                  );
                  _updateState(() {});
                },
              )
            : Radio<String>(
                value: choice.id,
                groupValue: cubit.getSingleChoiceAnswer(question.id),
                activeColor: const Color(0xFF7A004C),
                onChanged: (_) {
                  cubit.setSingleChoiceAnswer(
                    questionId: question.id,
                    choiceId: choice.id,
                    score: score,
                  );
                  _updateState(() {});
                },
              ),
        SizedBox(width: responsiveSize(context, 0.008, min: 4, max: 6)),
        Flexible(
          child: customText(
            text: choice.label ?? "",
            size: responsiveHeight(context, 0.018, min: 13, max: 17),
            bold: selected,
            color: const Color(0xFF7A004C),
          ),
        ),
      ],
    );
  }

  Widget _scoreBadge(dynamic score) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.012, min: 8, max: 10),
        vertical: responsiveHeight(context, 0.006, min: 4, max: 5),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E8FF),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 10, max: 12),
        ),
      ),
      child: customText(
        text: "$score نقطة",
        size: responsiveHeight(context, 0.014, min: 11, max: 13),
        bold: true,
        color: const Color(0xFF7A00C4),
      ),
    );
  }

  Widget _notesField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.02, min: 14, max: 20)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.024, min: 18, max: 24),
        ),
        border: Border.all(color: const Color(0xFFFFB6D9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE40070).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customText(
                text: localizedText(context, 'ملاحظات الطبيب'),
                size: responsiveHeight(context, 0.021, min: 15, max: 21),
                bold: true,
                color: const Color(0xFF7A004C),
              ),
              SizedBox(width: responsiveSize(context, 0.01, min: 6, max: 8)),
              Icon(
                Icons.edit_note_rounded,
                color: const Color(0xFFE40070),
                size: responsiveSize(context, 0.028, min: 22, max: 28),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.014, min: 10, max: 14)),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomFormTextField(
              controller: noteController,
              hintText: localizedText(context, 'اكتب ملاحظات الطبيب هنا...'),
              autovalidateMode: AutovalidateMode.disabled,
              keyboardType: CustomTextFieldType.text,
              maxLines: 4,
              bordered: false,
              centerHint: false,
            ),
          ),
        ],
      ),
    );
  }
}
