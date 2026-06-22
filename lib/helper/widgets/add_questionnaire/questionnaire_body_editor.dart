part of 'questionnaire_body_widgets.dart';

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
                  color: Colors.black.withValues(alpha: .08),
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
        border: Border.all(color: Colors.purple.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: appCrossAxisAlignment(isEnglish),
        children: [
          sectionLabel(
            label: context.l10n.scaleRating,
            icon: Icons.linear_scale_rounded,
            w: w,
          ),
          const SizedBox(height: 14),
          if (isMobile) ...[
            CustomFormTextField(

              keyboardType: CustomTextFieldType.score,
              labelText: context.l10n.minimumValue,
              hintText: '0',
              controller: minValueController,
              centerHint: true,
            ),
            const SizedBox(height: 12),
            CustomFormTextField(

              keyboardType: CustomTextFieldType.score,
              labelText: context.l10n.maximumValue,
              hintText: '10',
              controller: maxValueController,
              centerHint: true,
            ),
            const SizedBox(height: 12),
            CustomFormTextField(

              keyboardType: CustomTextFieldType.text,
              labelText: context.l10n.minimumLabel,
              hintText: context.l10n.none,
              controller: minLabelController,
              isRequired: false,
              textDirection: appTextDirection(isEnglish),
            ),
            const SizedBox(height: 12),
            CustomFormTextField(

              keyboardType: CustomTextFieldType.text,
              labelText: context.l10n.maximumLabel,
              hintText: context.l10n.verySevere,
              controller: maxLabelController,
              isRequired: false,
              textDirection: appTextDirection(isEnglish),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CustomFormTextField(
                  
                    keyboardType: CustomTextFieldType.score,
                    labelText: context.l10n.minimumValue,
                    hintText: '0',
                    controller: minValueController,
                    centerHint: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormTextField(
                  
                    keyboardType: CustomTextFieldType.score,
                    labelText: context.l10n.maximumValue,
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
                 
                    keyboardType: CustomTextFieldType.text,
                    labelText: context.l10n.minimumLabel,
                    hintText: context.l10n.none,
                    controller: minLabelController,
                    isRequired: false,
                    textDirection: appTextDirection(isEnglish),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomFormTextField(
                 
                    keyboardType: CustomTextFieldType.text,
                    labelText: context.l10n.maximumLabel,
                    hintText: context.l10n.verySevere,
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
