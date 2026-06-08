import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';


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
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Column(
          crossAxisAlignment: appCrossAxisAlignment(isEnglish),
          children: [
            sectionLabel(
              label: 'نوع السؤال',
              icon: Icons.format_list_bulleted_rounded,
              w: 1,
            ),
            const SizedBox(height: 12),
            Row(
              textDirection: appTextDirection(isEnglish),
              children: [
                Expanded(
                  child: QuestionTypeCard(
                    title: 'اختيار واحد',
                    subtitle: 'يمكن للمستخدم اختيار إجابة واحدة فقط',
                    icon: Icons.radio_button_checked_rounded,
                    isSelected: selectedType == QuestionType.single,
                    onTap: () => onChanged(QuestionType.single),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: QuestionTypeCard(
                    title: 'اختيار متعدد',
                    subtitle: 'يمكن للمستخدم اختيار أكثر من إجابة',
                    icon: Icons.checklist_rounded,
                    isSelected: selectedType == QuestionType.multiple,
                    onTap: () => onChanged(QuestionType.multiple),
                  ),
                ),
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
    final w = getScreenWidth(context);

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.purple.withOpacity(.07) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? Colors.purple : Colors.grey.shade200,
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: isEnglish
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (isEnglish) ...[
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? surveyPurple : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 10),
                  Icon(icon, color: isSelected ? surveyPurple : surveyPink),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: appCrossAxisAlignment(isEnglish),
                    children: [
                      customText(
                        text: title,
                        color: surveyDark,
                        bold: true,
                        size: w * 0.01,
                        isCenter: false,
                        align: isEnglish ? TextAlign.end : TextAlign.start,
                        isEnglish: isEnglish,
                      ),
                      const SizedBox(height: 5),
                      customText(
                        text: subtitle,
                        color: Colors.grey.shade500,
                        size: w * 0.009,
                        bold: false,
                        isCenter: false,
                        align: isEnglish ? TextAlign.end : TextAlign.start,
                        isEnglish: isEnglish,
                      ),
                    ],
                  ),
                ),
                if (!isEnglish) ...[
                  const SizedBox(width: 10),
                  Icon(icon, color: isSelected ? surveyPurple : surveyPink),
                  const SizedBox(width: 10),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: isSelected ? surveyPurple : Colors.grey.shade400,
                  ),
                ],
              ],
            ),
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Row(
          textDirection: TextDirection.ltr,
          mainAxisAlignment: isEnglish
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (isEnglish) ...[
              IconButton(
                onPressed: canDelete ? onDelete : null,
                icon: Icon(
                  Icons.close_rounded,
                  color: canDelete
                      ? Colors.grey.shade500
                      : Colors.grey.shade300,
                ),
              ),
            ],
            Expanded(
              child: Directionality(
                textDirection: appTextDirection(isEnglish),
                child: CustomFormTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: CustomTextFieldType.text,
                  hintText: localizedText(context, 'اكتب خيار'),
                  controller: answer.answerController,
                  textDirection: appTextDirection(isEnglish),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ScoreInput(controller: answer.scoreController),
            if (!isEnglish) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: canDelete ? onDelete : null,
                icon: Icon(
                  Icons.close_rounded,
                  color: canDelete
                      ? Colors.grey.shade500
                      : Colors.grey.shade300,
                ),
              ),
            ],
          ],
        );
      },
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

    questionType = type == "SINGLE_SELECT"
        ? QuestionType.single
        : QuestionType.multiple;

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
    );
  }

  @override
  void dispose() {
    questionController.dispose();

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

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surveyCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.2),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: customText(
                          text: 'السؤال ${widget.questionIndex}',
                          color: Colors.white,
                          size: w * 0.009,
                          isEnglish: isEnglish,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: widget.canDeleteQuestion
                            ? widget.onDeleteQuestion
                            : null,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: widget.canDeleteQuestion
                              ? surveyPink
                              : Colors.grey.shade300,
                          size: w * 0.014,
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        onPressed: widget.canDeleteQuestion
                            ? widget.onDeleteQuestion
                            : null,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: widget.canDeleteQuestion
                              ? surveyPink
                              : Colors.grey.shade300,
                          size: w * 0.014,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: customText(
                          text: 'السؤال ${widget.questionIndex}',
                          color: Colors.white,
                          size: w * 0.009,
                          isEnglish: isEnglish,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 25),
                LabeledInput(
                  w: w,
                  label: localizedText(context, 'نص السؤال'),
                  hint: localizedText(context, 'اكتب السؤال هنا'),
                  controller: questionController,
                  icon: Icons.help_outline_rounded,
                ),
                const SizedBox(height: 24),
                QuestionTypeSelector(
                  selectedType: questionType,
                  onChanged: (value) => setState(() => questionType = value),
                ),
                const SizedBox(height: 24),
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
            ),
          ),
        );
      },
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
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.deepPurpleAccent.withOpacity(.2),
              ),
            ),
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: isEnglish
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (isEnglish) ...[
                  IconButton(
                    onPressed: canDelete ? onDelete : null,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: canDelete ? surveyPink : Colors.grey.shade300,
                    ),
                  ),
                ],
                Expanded(
                  child: CustomFormTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.score,
                    labelText: localizedText(context, 'من'),
                    centerHint: true,
                    hintText: localizedText(context, '0'),
                    controller: item.fromController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomFormTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.score,
                    labelText: localizedText(context, 'إلى'),
                    centerHint: true,
                    hintText: localizedText(context, '100'),
                    controller: item.toController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: CustomFormTextField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.diagnose,
                    hintText: localizedText(context, 'اكتب التشخيص'),
                    controller: item.diagnosisController,
                    textDirection: appTextDirection(isEnglish),
                  ),
                ),
                if (!isEnglish) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: canDelete ? onDelete : null,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: canDelete ? surveyPink : Colors.grey.shade300,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF7FF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.2),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
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
                    size: w * 0.011,
                    isEnglish: isEnglish,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: customText(
                    text: 'يمكنك تحديد تشخيص لكل نطاق من السكور الكلي',
                    color: Colors.deepPurple[300],
                    size: w * 0.009,
                    isEnglish: isEnglish,
                  ),
                ),
                const SizedBox(height: 22),
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
            Icon(Icons.assignment_add, size: w * 0.04, color: Colors.pink),
            const SizedBox(height: 8),
            customText(
              text: 'إنشاء استبيان جديد',
              color: surveyDark,
              size: w * 0.013,
              isEnglish: isEnglish,
            ),
            const SizedBox(height: 7),
            customText(
              text: 'قم بإضافة الأسئلة والإجابات',
              color: Colors.grey.shade500,
              size: w * 0.009,
              isEnglish: isEnglish,
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.2),
                  blurRadius: 18,
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
