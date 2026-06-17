import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuestionItem {
  final int id;
  final GlobalKey<QuestionnaireBodyState> key;
  bool isDeleting;
  final Map<String, dynamic>? initialData;

  QuestionItem({
    required this.id,
    required this.key,
    this.isDeleting = false,
    this.initialData,
  });
}

class QuestionTypeSelector extends StatelessWidget {
  const QuestionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final QuestionType selectedType;
  final ValueChanged<QuestionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isMobile = w < 700;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        final cards = [
          QuestionTypeCard(
            title: 'اختيار واحد',
            subtitle: 'يمكن للمستخدم اختيار إجابة واحدة فقط',
            icon: Icons.radio_button_checked_rounded,
            isSelected: selectedType == QuestionType.single,
            onTap: () => onChanged(QuestionType.single),
          ),
          QuestionTypeCard(
            title: 'اختيار متعدد',
            subtitle: 'يمكن للمستخدم اختيار أكثر من إجابة',
            icon: Icons.checklist_rounded,
            isSelected: selectedType == QuestionType.multiple,
            onTap: () => onChanged(QuestionType.multiple),
          ),
          QuestionTypeCard(
            title: 'Scale / Rating',
            subtitle: 'اختيار درجة من نطاق رقمي مثل 0 إلى 10',
            icon: Icons.linear_scale_rounded,
            isSelected: selectedType == QuestionType.scale,
            onTap: () => onChanged(QuestionType.scale),
          ),
        ];

        return Column(
          crossAxisAlignment: appCrossAxisAlignment(isEnglish),
          children: [
            sectionLabel(
              label: 'نوع السؤال',
              icon: Icons.format_list_bulleted_rounded,
              w: w,
            ),
            const SizedBox(height: 12),
            if (isMobile)
              Column(
                children: cards
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(width: double.infinity, child: card),
                      ),
                    )
                    .toList(),
              )
            else
              Row(
                textDirection: appTextDirection(isEnglish),
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 14),
                  Expanded(child: cards[1]),
                  const SizedBox(width: 14),
                  Expanded(child: cards[2]),
                ],
              ),
          ],
        );
      },
    );
  }
}

class QuestionTypeCard extends StatelessWidget {
  const QuestionTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return InkWell(
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.014, min: 14, max: 18),
          ),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.014, min: 14, max: 18),
            ),
            decoration: BoxDecoration(
              color: isSelected ? surveyPurple.withOpacity(.07) : Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.014, min: 14, max: 18),
              ),
              border: Border.all(
                color: isSelected ? surveyPurple : Colors.grey.shade200,
                width: isSelected ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? surveyPurple.withOpacity(.12)
                      : Colors.black.withOpacity(.035),
                  blurRadius: isSelected ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: isMobile
                ? Row(
                    textDirection: appTextDirection(isEnglish),
                    children: [
                      _typeIcon(context),
                      const SizedBox(width: 12),
                      Expanded(child: _textBlock(context, isEnglish)),
                      const SizedBox(width: 8),
                      _selectedIcon(context),
                    ],
                  )
                : Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: isEnglish
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      if (isEnglish) ...[
                        _selectedIcon(context),
                        const SizedBox(width: 10),
                        _typeIcon(context),
                        const SizedBox(width: 10),
                      ],
                      Expanded(child: _textBlock(context, isEnglish)),
                      if (!isEnglish) ...[
                        const SizedBox(width: 10),
                        _typeIcon(context),
                        const SizedBox(width: 10),
                        _selectedIcon(context),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _typeIcon(BuildContext context) {
    return Container(
      width: responsiveSize(context, 0.034, min: 40, max: 48),
      height: responsiveSize(context, 0.034, min: 40, max: 48),
      decoration: BoxDecoration(
        color: isSelected
            ? surveyPurple.withOpacity(.12)
            : surveyPink.withOpacity(.08),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.01, min: 12, max: 15),
        ),
      ),
      child: Icon(
        icon,
        color: isSelected ? surveyPurple : surveyPink,
        size: responsiveSize(context, 0.018, min: 22, max: 28),
      ),
    );
  }

  Widget _selectedIcon(BuildContext context) {
    return Icon(
      isSelected
          ? Icons.check_circle_rounded
          : Icons.radio_button_unchecked_rounded,
      color: isSelected ? surveyPurple : Colors.grey.shade400,
      size: responsiveSize(context, 0.018, min: 22, max: 27),
    );
  }

  Widget _textBlock(BuildContext context, bool isEnglish) {
    return Column(
      crossAxisAlignment: appCrossAxisAlignment(isEnglish),
      children: [
        customText(
          text: title,
          color: surveyDark,
          bold: true,
          size: responsiveSize(context, 0.0095, min: 13, max: 17),
          isCenter: false,
          align: isEnglish ? TextAlign.start : TextAlign.right,
          isEnglish: isEnglish,
          maxLines: 1,
        ),
        const SizedBox(height: 5),
        customText(
          text: subtitle,
          color: Colors.grey.shade500,
          size: responsiveSize(context, 0.008, min: 11, max: 14),
          bold: false,
          isCenter: false,
          align: isEnglish ? TextAlign.start : TextAlign.right,
          isEnglish: isEnglish,
          maxLines: 2,
        ),
      ],
    );
  }
}

class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    super.key,
    required this.answer,
    required this.canDelete,
    required this.onDelete,
  });

  final AnswerItemModel answer;
  final bool canDelete;
  final VoidCallback onDelete;

  void _limitScoreTo100(String value) {
    if (value.trim().isEmpty) return;

    final number = int.tryParse(value);
    if (number == null) return;

    if (number > 100) {
      answer.scoreController.text = '100';
      answer.scoreController.selection = TextSelection.fromPosition(
        TextPosition(offset: answer.scoreController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        final answerField = _AnswerField(answer: answer, isEnglish: isEnglish);

        final scoreField = _ScoreField(
          answer: answer,
          isEnglish: isEnglish,
          onChanged: _limitScoreTo100,
        );

        final deleteButton = _DeleteAnswerButton(
          canDelete: canDelete,
          onDelete: onDelete,
        );

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: Container(
            margin: EdgeInsets.only(
              bottom: responsiveHeight(context, 0.016, min: 12, max: 18),
            ),
            padding: EdgeInsets.all(
              responsiveSize(context, 0.012, min: 12, max: 18),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.012, min: 14, max: 20),
              ),
              border: Border.all(color: surveyPink.withOpacity(.18)),
              boxShadow: [
                BoxShadow(
                  color: surveyPink.withOpacity(.055),
                  blurRadius: responsiveSize(context, 0.018, min: 14, max: 24),
                  offset: Offset(
                    0,
                    responsiveHeight(context, 0.008, min: 5, max: 9),
                  ),
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: answerField),
                          SizedBox(
                            width: responsiveSize(
                              context,
                              0.025,
                              min: 10,
                              max: 14,
                            ),
                          ),
                          deleteButton,
                        ],
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.014,
                          min: 10,
                          max: 14,
                        ),
                      ),
                      scoreField,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(flex: 5, child: answerField),
                      SizedBox(
                        width: responsiveSize(context, 0.018, min: 12, max: 18),
                      ),
                      SizedBox(
                        width: responsiveSize(
                          context,
                          0.09,
                          min: 105,
                          max: 140,
                        ),
                        child: scoreField,
                      ),
                      SizedBox(
                        width: responsiveSize(context, 0.014, min: 10, max: 14),
                      ),
                      deleteButton,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _AnswerField extends StatelessWidget {
  const _AnswerField({required this.answer, required this.isEnglish});

  final AnswerItemModel answer;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: appCrossAxisAlignment(isEnglish),
      children: [
        customText(
          text: localizedText(context, 'الإجابة'),
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          color: surveyDark,
          bold: true,
          isCenter: false,
          isEnglish: isEnglish,
        ),
        SizedBox(height: responsiveHeight(context, 0.009, min: 7, max: 10)),
        TextField(
          controller: answer.answerController,
          textDirection: appTextDirection(isEnglish),
          textAlign: isEnglish ? TextAlign.start : TextAlign.right,
          decoration: InputDecoration(
            hintText: localizedText(context, 'اكتب خيار'),
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontFamily: 'ArabicCustomFont',
              fontSize: responsiveSize(context, 0.008, min: 12, max: 15),
            ),
            filled: true,
            fillColor: const Color(0xFFFFFBFE),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 12, max: 18),
              vertical: responsiveHeight(context, 0.016, min: 13, max: 18),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
              borderSide: BorderSide(color: surveyPink.withOpacity(.55)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
              borderSide: const BorderSide(color: surveyPink, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
            ),
          ),
          style: TextStyle(
            fontFamily: 'ArabicCustomFont',
            fontWeight: FontWeight.w600,
            color: surveyDark,
            fontSize: responsiveSize(context, 0.0085, min: 13, max: 16),
          ),
        ),
      ],
    );
  }
}

class _ScoreField extends StatelessWidget {
  const _ScoreField({
    required this.answer,
    required this.isEnglish,
    required this.onChanged,
  });

  final AnswerItemModel answer;
  final bool isEnglish;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    return Column(
      crossAxisAlignment: isMobile
          ? appCrossAxisAlignment(isEnglish)
          : CrossAxisAlignment.center,
      children: [
        customText(
          text: localizedText(context, 'الدرجة'),
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          color: surveyPurple,
          bold: true,
          isCenter: !isMobile,
          isEnglish: isEnglish,
        ),
        SizedBox(height: responsiveHeight(context, 0.009, min: 7, max: 10)),
        TextField(
          controller: answer.scoreController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 3,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            counterText: '',
            hintText: '0',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontFamily: 'ArabicCustomFont',
              fontSize: responsiveSize(context, 0.008, min: 12, max: 15),
            ),
            filled: true,
            fillColor: const Color(0xFFFFFBFE),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.01, min: 10, max: 14),
              vertical: responsiveHeight(context, 0.016, min: 13, max: 18),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
              borderSide: BorderSide(color: surveyPurple.withOpacity(.45)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
              borderSide: const BorderSide(color: surveyPurple, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
            ),
          ),
          style: TextStyle(
            fontFamily: 'ArabicCustomFont',
            fontWeight: FontWeight.bold,
            color: surveyDark,
            fontSize: responsiveSize(context, 0.009, min: 13, max: 17),
          ),
        ),
      ],
    );
  }
}

class _DeleteAnswerButton extends StatelessWidget {
  const _DeleteAnswerButton({required this.canDelete, required this.onDelete});

  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsiveSize(context, 0.034, min: 40, max: 48),
      height: responsiveSize(context, 0.034, min: 40, max: 48),
      decoration: BoxDecoration(
        color: canDelete
            ? surveyPink.withOpacity(.08)
            : Colors.grey.withOpacity(.06),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.01, min: 12, max: 15),
        ),
        border: Border.all(
          color: canDelete
              ? surveyPink.withOpacity(.25)
              : Colors.grey.withOpacity(.15),
        ),
      ),
      child: IconButton(
        onPressed: canDelete ? onDelete : null,
        icon: Icon(
          Icons.delete_outline_rounded,
          color: canDelete ? surveyPink : Colors.grey.shade300,
          size: responsiveSize(context, 0.015, min: 18, max: 23),
        ),
        tooltip: localizedText(context, 'حذف'),
      ),
    );
  }
}

class QuestionnaireBody extends StatefulWidget {
  const QuestionnaireBody({
    super.key,
    required this.questionIndex,
    required this.canDeleteQuestion,
    required this.onDeleteQuestion,
    this.initialData,
  });

  final int questionIndex;
  final bool canDeleteQuestion;
  final VoidCallback onDeleteQuestion;
  final Map<String, dynamic>? initialData;

  @override
  State<QuestionnaireBody> createState() => QuestionnaireBodyState();
}

class QuestionnaireBodyState extends State<QuestionnaireBody> {
  QuestionType questionType = QuestionType.multiple;
  final TextEditingController questionController = TextEditingController();
  final TextEditingController minValueController = TextEditingController(
    text: '0',
  );
  final TextEditingController maxValueController = TextEditingController(
    text: '10',
  );
  final TextEditingController minLabelController = TextEditingController();
  final TextEditingController maxLabelController = TextEditingController();
  final List<AnswerItemModel> answers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final data = widget.initialData;

    if (data == null) {
      answers.addAll([AnswerItemModel(), AnswerItemModel()]);
      return;
    }

    questionController.text = data["text"]?.toString() ?? "";

    final type = data["type"]?.toString() ?? "MULTI_SELECT";

    if (type == "SCALE") {
      questionType = QuestionType.scale;
      minValueController.text = data["scaleMin"]?.toString() ?? "0";
      maxValueController.text = data["scaleMax"]?.toString() ?? "10";
      minLabelController.text = data["minLabel"]?.toString() ?? "";
      maxLabelController.text = data["maxLabel"]?.toString() ?? "";
    } else {
      questionType = type == "SINGLE_SELECT" || type == "SINGLE_CHOICE"
          ? QuestionType.single
          : QuestionType.multiple;
    }

    final choices = data["choices"] as List? ?? [];

    if (choices.isEmpty) {
      answers.addAll([AnswerItemModel(), AnswerItemModel()]);
      return;
    }

    for (final choice in choices) {
      answers.add(
        AnswerItemModel(
          answer: choice["label"]?.toString() ?? "",
          score: choice["score"]?.toString() ?? "0",
        ),
      );
    }

    if (answers.length < 2) {
      answers.add(AnswerItemModel());
    }
  }

  QuestionValidationData getQuestionData() {
    return QuestionValidationData(
      questionText: questionController.text.trim(),
      questionType: questionType,
      answers: answers.map((answer) {
        return AnswerValidationData(
          answerText: answer.answerController.text.trim(),
          score: int.tryParse(answer.scoreController.text.trim()) ?? -1,
        );
      }).toList(),
      minValue: int.tryParse(minValueController.text.trim()),
      maxValue: int.tryParse(maxValueController.text.trim()),
      minLabel: minLabelController.text.trim(),
      maxLabel: maxLabelController.text.trim(),
    );
  }

  @override
  void dispose() {
    questionController.dispose();
    minValueController.dispose();
    maxValueController.dispose();
    minLabelController.dispose();
    maxLabelController.dispose();

    for (final answer in answers) {
      answer.dispose();
    }

    super.dispose();
  }

  void addAnswer() {
    setState(() => answers.add(AnswerItemModel()));
  }

  void removeAnswer(int index) {
    if (answers.length <= 2) return;

    setState(() {
      answers[index].isDeleting = true;
    });
  }

  void deleteAnswerAfterAnimation(int index) {
    if (index < 0 || index >= answers.length) return;

    final removedAnswer = answers[index];

    setState(() {
      answers.removeAt(index);
    });

    removedAnswer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isMobile = w < 700;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: Container(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.018, min: 14, max: 24),
            ),
            decoration: BoxDecoration(
              color: surveyCard,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.018, min: 16, max: 22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: appCrossAxisAlignment(isEnglish),
              children: [
                Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: isEnglish
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    if (isEnglish) ...[
                      _questionBadge(context, w, isEnglish),
                      const Spacer(),
                      _deleteQuestionButton(w),
                    ] else ...[
                      _deleteQuestionButton(w),
                      const Spacer(),
                      _questionBadge(context, w, isEnglish),
                    ],
                  ],
                ),
                SizedBox(height: isMobile ? 18 : 25),
                LabeledInput(
                  w: w,
                  label: localizedText(context, 'نص السؤال'),
                  hint: localizedText(context, 'اكتب السؤال هنا'),
                  controller: questionController,
                  icon: Icons.help_outline_rounded,
                ),
                SizedBox(height: isMobile ? 18 : 24),
                QuestionTypeSelector(
                  selectedType: questionType,
                  onChanged: (value) => setState(() => questionType = value),
                ),
                SizedBox(height: isMobile ? 18 : 24),
                if (questionType != QuestionType.scale) ...[
                  sectionLabel(
                    label: 'الخيارات',
                    icon: Icons.format_list_bulleted_rounded,
                    w: w,
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    answers.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: answers[index].isDeleting
                          ? AnimatedRemove(
                              onAnimationEnd: () =>
                                  deleteAnswerAfterAnimation(index),
                              child: AnswerOptionTile(
                                answer: answers[index],
                                canDelete: false,
                                onDelete: () {},
                              ),
                            )
                          : AnimatedAdd(
                              key: ValueKey(answers[index]),
                              child: AnswerOptionTile(
                                answer: answers[index],
                                canDelete: answers.length > 2,
                                onDelete: () => removeAnswer(index),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: AddOutlineButton(
                      title: 'إضافة خيار',
                      onPressed: addAnswer,
                    ),
                  ),
                ],
                if (questionType == QuestionType.scale)
                  _scaleEditor(w: w, isEnglish: isEnglish),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _questionBadge(BuildContext context, double w, bool isEnglish) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.018, min: 16, max: 22),
        vertical: responsiveHeight(context, 0.012, min: 8, max: 10),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(10),
      ),
      child: customText(
        text: 'السؤال ${widget.questionIndex}',
        color: Colors.white,
        size: responsiveSize(context, 0.0085, min: 12, max: 15),
        isEnglish: isEnglish,
      ),
    );
  }

  Widget _deleteQuestionButton(double w) {
    return IconButton(
      onPressed: widget.canDeleteQuestion ? widget.onDeleteQuestion : null,
      icon: Icon(
        Icons.delete_outline_rounded,
        color: widget.canDeleteQuestion ? surveyPink : Colors.grey.shade300,
        size: responsiveSize(context, 0.018, min: 22, max: 28),
      ),
    );
  }

  Widget _scaleEditor({required double w, required bool isEnglish}) {
    final isMobile = w < 700;

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.014, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.withOpacity(.18)),
      ),
      child: Column(
        crossAxisAlignment: appCrossAxisAlignment(isEnglish),
        children: [
          sectionLabel(
            label: 'Scale / Rating',
            icon: Icons.linear_scale_rounded,
            w: w,
          ),
          const SizedBox(height: 14),
          if (isMobile) ...[
            CustomFormTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: CustomTextFieldType.score,
              labelText: 'minValue',
              hintText: '0',
              controller: minValueController,
              centerHint: true,
            ),
            const SizedBox(height: 12),
            CustomFormTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: CustomTextFieldType.score,
              labelText: 'maxValue',
              hintText: '10',
              controller: maxValueController,
              centerHint: true,
            ),
            const SizedBox(height: 12),
            CustomFormTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: CustomTextFieldType.text,
              labelText: 'minLabel',
              hintText: 'لا يوجد',
              controller: minLabelController,
              isRequired: false,
              textDirection: appTextDirection(isEnglish),
            ),
            const SizedBox(height: 12),
            CustomFormTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: CustomTextFieldType.text,
              labelText: 'maxLabel',
              hintText: 'شديد جدًا',
              controller: maxLabelController,
              isRequired: false,
              textDirection: appTextDirection(isEnglish),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CustomFormTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.score,
                    labelText: 'minValue',
                    hintText: '0',
                    controller: minValueController,
                    centerHint: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.score,
                    labelText: 'maxValue',
                    hintText: '10',
                    controller: maxValueController,
                    centerHint: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomFormTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.text,
                    labelText: 'minLabel',
                    hintText: 'لا يوجد',
                    controller: minLabelController,
                    isRequired: false,
                    textDirection: appTextDirection(isEnglish),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.text,
                    labelText: 'maxLabel',
                    hintText: 'شديد جدًا',
                    controller: maxLabelController,
                    isRequired: false,
                    textDirection: appTextDirection(isEnglish),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          customText(
            text:
                'سيتم إنشاء اختيارات تلقائية لكل قيمة داخل النطاق، والـ score يساوي القيمة المختارة.',
            color: Colors.grey.shade600,
            size: responsiveSize(context, 0.008, min: 11, max: 14),
            isCenter: false,
            isEnglish: isEnglish,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class DiagnosisMiniCard extends StatelessWidget {
  const DiagnosisMiniCard({
    super.key,
    required this.item,
    required this.canDelete,
    required this.onDelete,
  });

  final DiagnosisItemModel item;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 700;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        final fromField = _DiagnosisNumberField(
          label: 'من',
          hint: '0',
          controller: item.fromController,
          isEnglish: isEnglish,
        );

        final toField = _DiagnosisNumberField(
          label: 'إلى',
          hint: '100',
          controller: item.toController,
          isEnglish: isEnglish,
        );

        final diagnosisField = _DiagnosisTextField(
          controller: item.diagnosisController,
          isEnglish: isEnglish,
        );

        final deleteButton = _DeleteDiagnosisButton(
          canDelete: canDelete,
          onDelete: onDelete,
        );

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: Container(
            margin: EdgeInsets.only(
              bottom: responsiveHeight(context, 0.014, min: 10, max: 16),
            ),
            padding: EdgeInsets.all(
              responsiveSize(context, 0.012, min: 12, max: 18),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.014, min: 16, max: 22),
              ),
              border: Border.all(color: surveyPurple.withOpacity(.18)),
              boxShadow: [
                BoxShadow(
                  color: surveyPurple.withOpacity(.07),
                  blurRadius: responsiveSize(context, 0.018, min: 14, max: 24),
                  offset: Offset(
                    0,
                    responsiveHeight(context, 0.008, min: 5, max: 9),
                  ),
                ),
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: fromField),
                          SizedBox(
                            width: responsiveSize(
                              context,
                              0.025,
                              min: 10,
                              max: 14,
                            ),
                          ),
                          Expanded(child: toField),
                          SizedBox(
                            width: responsiveSize(
                              context,
                              0.025,
                              min: 10,
                              max: 14,
                            ),
                          ),
                          deleteButton,
                        ],
                      ),
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.014,
                          min: 10,
                          max: 14,
                        ),
                      ),
                      diagnosisField,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: responsiveSize(
                          context,
                          0.075,
                          min: 90,
                          max: 125,
                        ),
                        child: fromField,
                      ),
                      SizedBox(
                        width: responsiveSize(context, 0.014, min: 10, max: 14),
                      ),
                      SizedBox(
                        width: responsiveSize(
                          context,
                          0.075,
                          min: 90,
                          max: 125,
                        ),
                        child: toField,
                      ),
                      SizedBox(
                        width: responsiveSize(context, 0.018, min: 12, max: 18),
                      ),
                      Expanded(child: diagnosisField),
                      SizedBox(
                        width: responsiveSize(context, 0.014, min: 10, max: 14),
                      ),
                      deleteButton,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _DiagnosisNumberField extends StatelessWidget {
  const _DiagnosisNumberField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.isEnglish,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: appCrossAxisAlignment(isEnglish),
      children: [
        customText(
          text: localizedText(context, label),
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          color: surveyPurple,
          bold: true,
          isCenter: false,
          isEnglish: isEnglish,
        ),
        SizedBox(height: responsiveHeight(context, 0.009, min: 7, max: 10)),
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 3,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(
            counterText: '',
            hintText: localizedText(context, hint),
            filled: true,
            fillColor: const Color(0xFFFFFBFE),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.01, min: 10, max: 14),
              vertical: responsiveHeight(context, 0.016, min: 13, max: 18),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
              borderSide: BorderSide(color: surveyPurple.withOpacity(.42)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
              borderSide: const BorderSide(color: surveyPurple, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
            ),
          ),
          style: TextStyle(
            fontFamily: 'ArabicCustomFont',
            fontWeight: FontWeight.bold,
            color: surveyDark,
            fontSize: responsiveSize(context, 0.009, min: 13, max: 17),
          ),
        ),
      ],
    );
  }
}

class _DiagnosisTextField extends StatelessWidget {
  const _DiagnosisTextField({
    required this.controller,
    required this.isEnglish,
  });

  final TextEditingController controller;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: appCrossAxisAlignment(isEnglish),
      children: [
        customText(
          text: localizedText(context, 'التشخيص'),
          size: responsiveSize(context, 0.0085, min: 12, max: 15),
          color: surveyDark,
          bold: true,
          isCenter: false,
          isEnglish: isEnglish,
        ),
        SizedBox(height: responsiveHeight(context, 0.009, min: 7, max: 10)),
        TextField(
          controller: controller,
          textDirection: appTextDirection(isEnglish),
          textAlign: isEnglish ? TextAlign.start : TextAlign.right,
          maxLength: 50,
          decoration: InputDecoration(
            counterText: '',
            hintText: localizedText(context, 'اكتب التشخيص'),
            filled: true,
            fillColor: const Color(0xFFFFFBFE),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.012, min: 12, max: 18),
              vertical: responsiveHeight(context, 0.016, min: 13, max: 18),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
              borderSide: BorderSide(color: surveyPurple.withOpacity(.35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
              borderSide: const BorderSide(color: surveyPurple, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.01, min: 12, max: 16),
              ),
            ),
          ),
          style: TextStyle(
            fontFamily: 'ArabicCustomFont',
            fontWeight: FontWeight.w600,
            color: surveyDark,
            fontSize: responsiveSize(context, 0.0085, min: 13, max: 16),
          ),
        ),
      ],
    );
  }
}

class _DeleteDiagnosisButton extends StatelessWidget {
  const _DeleteDiagnosisButton({
    required this.canDelete,
    required this.onDelete,
  });

  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsiveSize(context, 0.034, min: 40, max: 48),
      height: responsiveSize(context, 0.034, min: 40, max: 48),
      decoration: BoxDecoration(
        color: canDelete
            ? surveyPink.withOpacity(.08)
            : Colors.grey.withOpacity(.06),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.01, min: 12, max: 15),
        ),
        border: Border.all(
          color: canDelete
              ? surveyPink.withOpacity(.25)
              : Colors.grey.withOpacity(.15),
        ),
      ),
      child: IconButton(
        onPressed: canDelete ? onDelete : null,
        icon: Icon(
          Icons.delete_outline_rounded,
          color: canDelete ? surveyPink : Colors.grey.shade300,
          size: responsiveSize(context, 0.015, min: 18, max: 23),
        ),
        tooltip: localizedText(context, 'حذف'),
      ),
    );
  }
}

class DiagnosisSection extends StatefulWidget {
  const DiagnosisSection({super.key});

  @override
  State<DiagnosisSection> createState() => DiagnosisSectionState();
}

class DiagnosisSectionState extends State<DiagnosisSection> {
  final List<DiagnosisItemModel> diagnosisItems = [DiagnosisItemModel()];

  List<DiagnosisRangeValidationData> getDiagnosisRanges() {
    return diagnosisItems.map((item) {
      return DiagnosisRangeValidationData(
        from: int.tryParse(item.fromController.text.trim()) ?? -1,
        to: int.tryParse(item.toController.text.trim()) ?? -1,
        diagnosis: item.diagnosisController.text.trim(),
      );
    }).toList();
  }

  void setDiagnosisRangesFromApi(List<dynamic> ranges) {
    for (final item in diagnosisItems) {
      item.dispose();
    }

    diagnosisItems.clear();

    for (final range in ranges) {
      diagnosisItems.add(
        DiagnosisItemModel(
          from: range["minScore"]?.toString() ?? "0",
          to: range["maxScore"]?.toString() ?? "100",
          diagnosis: range["label"]?.toString() ?? "",
        ),
      );
    }

    if (diagnosisItems.isEmpty) {
      diagnosisItems.add(DiagnosisItemModel());
    }

    setState(() {});
  }

  void resetRanges() {
    for (final item in diagnosisItems) {
      item.dispose();
    }

    diagnosisItems.clear();
    diagnosisItems.add(DiagnosisItemModel());

    setState(() {});
  }

  @override
  void dispose() {
    for (final item in diagnosisItems) {
      item.dispose();
    }

    super.dispose();
  }

  void addDiagnosis() {
    setState(() => diagnosisItems.add(DiagnosisItemModel()));
  }

  void removeDiagnosis(int index) {
    if (diagnosisItems.length == 1) return;

    setState(() {
      diagnosisItems[index].isDeleting = true;
    });
  }

  void deleteDiagnosisAfterAnimation(int index) {
    if (index < 0 || index >= diagnosisItems.length) return;

    final removedItem = diagnosisItems[index];

    setState(() {
      diagnosisItems.removeAt(index);
    });

    removedItem.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isMobile = w < 700;

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: Container(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.018, min: 14, max: 24),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF7FF),
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.018, min: 16, max: 22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: appCrossAxisAlignment(isEnglish),
              children: [
                Center(
                  child: customText(
                    text: 'إعداد التشخيص الكلي للفورم',
                    color: Colors.deepPurple[400],
                    bold: true,
                    size: responsiveSize(context, 0.011, min: 15, max: 20),
                    isEnglish: isEnglish,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: customText(
                    text: 'يمكنك تحديد تشخيص لكل نطاق من السكور الكلي',
                    color: Colors.deepPurple[300],
                    size: responsiveSize(context, 0.009, min: 12, max: 16),
                    isEnglish: isEnglish,
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 22),
                ...List.generate(
                  diagnosisItems.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: diagnosisItems[index].isDeleting
                        ? AnimatedRemove(
                            onAnimationEnd: () =>
                                deleteDiagnosisAfterAnimation(index),
                            child: DiagnosisMiniCard(
                              item: diagnosisItems[index],
                              canDelete: false,
                              onDelete: () {},
                            ),
                          )
                        : AnimatedAdd(
                            key: ValueKey(diagnosisItems[index]),
                            child: DiagnosisMiniCard(
                              item: diagnosisItems[index],
                              canDelete: diagnosisItems.length > 1,
                              onDelete: () => removeDiagnosis(index),
                            ),
                          ),
                  ),
                ),
                Center(
                  child: AddOutlineButton(
                    title: 'إضافة تشخيص جديد',
                    color: surveyPurple,
                    onPressed: addDiagnosis,
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

class QuestionnairePageHeader extends StatelessWidget {
  const QuestionnairePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Column(
          children: [
            Icon(
              Icons.assignment_add,
              size: responsiveSize(context, 0.04, min: 44, max: 72),
              color: Colors.pink,
            ),
            const SizedBox(height: 8),
            customText(
              text: 'إنشاء استبيان جديد',
              color: surveyDark,
              size: responsiveSize(context, 0.013, min: 18, max: 26),
              bold: true,
              isEnglish: isEnglish,
              maxLines: 2,
            ),
            const SizedBox(height: 7),
            customText(
              text: 'قم بإضافة الأسئلة والإجابات',
              color: Colors.grey.shade500,
              size: responsiveSize(context, 0.009, min: 12, max: 16),
              isEnglish: isEnglish,
              maxLines: 2,
            ),
          ],
        );
      },
    );
  }
}

class SurveyTitleCard extends StatelessWidget {
  const SurveyTitleCard({
    super.key,
    required this.controller,
    required this.isEditing,
  });

  final TextEditingController controller;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: Container(
            padding: EdgeInsets.all(
              responsiveSize(context, 0.018, min: 14, max: 22),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LabeledInput(
              w: w,
              label: 'عنوان الاستبيان',
              hint: 'اكتب اسم الاستبيان',
              controller: controller,
              isTitle: true,
              icon: Icons.assignment_outlined,
              isEditing: isEditing,
            ),
          ),
        );
      },
    );
  }
}
