import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum QuestionType { single, multiple }

const Color surveyPink = Color(0xFFFF4F93);
const Color surveyPurple = Color(0xFF8E3FD1);
const Color surveyDark = Color(0xFF3B1038);
const Color surveyCard = Color(0xFFFFFBFE);

class AnswerItemModel {
  final TextEditingController answerController = TextEditingController();
  final TextEditingController scoreController = TextEditingController(
    text: '0',
  );
bool isDeleting = false;
  void dispose() {
    answerController.dispose();
    scoreController.dispose();
  }
}

class AnswerValidationData {
  final String answerText;
  final int score;

  AnswerValidationData({required this.answerText, required this.score});
}

class QuestionValidationData {
  final String questionText;
  final QuestionType questionType;
  final List<AnswerValidationData> answers;

  QuestionValidationData({
    required this.questionText,
    required this.questionType,
    required this.answers,
  });
}

class DiagnosisRangeValidationData {
  final int from;
  final int to;
  final String diagnosis;

  DiagnosisRangeValidationData({
    required this.from,
    required this.to,
    required this.diagnosis,
  });
}

class DiagnosisItemModel {
  final TextEditingController fromController = TextEditingController(text: '0');
  final TextEditingController toController = TextEditingController(text: '100');
  final TextEditingController diagnosisController = TextEditingController();
bool isDeleting = false;
  void dispose() {
    fromController.dispose();
    toController.dispose();
    diagnosisController.dispose();
  }
}

class AnimatedAdd extends StatelessWidget {
  const AnimatedAdd({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1).toDouble(),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 28),
            child: Transform.scale(scale: 0.92 + (value * 0.08), child: child),
          ),
        );
      },
      child: child,
    );
  }
}

class AnimatedRemove extends StatefulWidget {
  const AnimatedRemove({
    super.key,
    required this.child,
    required this.onAnimationEnd,
  });

  final Widget child;
  final VoidCallback onAnimationEnd;

  @override
  State<AnimatedRemove> createState() => _AnimatedRemoveState();
}

class _AnimatedRemoveState extends State<AnimatedRemove> {
  double value = 1;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (mounted) setState(() => value = 0);
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) widget.onAnimationEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: value,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        transform: Matrix4.translationValues((1 - value) * 35, 0, 0),
        child: widget.child,
      ),
    );
  }
}

Widget sectionLabel({
  required String label,
  required IconData? icon,
  required double w,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      if (icon != null) ...[
        Icon(icon, color: surveyPurple, size: w * 0.012),
        const SizedBox(width: 10),
      ],
      customText(text: label, color: surveyDark, bold: true, size: w * 0.01),
    ],
  );
}

class LabeledInput extends StatelessWidget {
  const LabeledInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    required this.w,
    this.isTitle = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final int maxLines;
  final double w;
  final bool isTitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel(label: label, icon: icon, w: w),
        const SizedBox(height: 8),
        CustomFormTextField(
          hintText: hint,
          keyboardType: isTitle
              ? CustomTextFieldType.title
              : CustomTextFieldType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          textDirection: TextDirection.rtl,
          maxLines: maxLines,
        ),
      ],
    );
  }
}

class AddOutlineButton extends StatelessWidget {
  const AddOutlineButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.color = surveyPink,
  });

  final String title;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(.65)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(
          fontFamily: 'ArabicCustomFont',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class GradientMainButton extends StatelessWidget {
  const GradientMainButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
  });

  final String title;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [surveyPink, surveyPurple]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: surveyPink.withOpacity(.22),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.add_circle_outline_rounded),
          label: Text(title),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'ArabicCustomFont',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionLabel(
          label: 'نوع السؤال',
          icon: Icons.format_list_bulleted_rounded,
          w: 1,
        ),
        const SizedBox(height: 12),
        Row(
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
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? surveyPurple : Colors.grey.shade400,
            ),
            const SizedBox(width: 10),
            Icon(icon, color: isSelected ? surveyPurple : surveyPink),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customText(
                    text: title,
                    color: surveyDark,
                    bold: true,
                    size: w * 0.01,
                  ),
                  const SizedBox(height: 5),
                  customText(
                    text: subtitle,
                    color: Colors.grey.shade500,
                    size: w * 0.009,
                    bold: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreInput extends StatelessWidget {
  const ScoreInput({super.key, required this.controller, this.width = 95});

  final TextEditingController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomFormTextField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: CustomTextFieldType.score,
        controller: controller,
        hintText: '0',
        prefixIcon: const Icon(Icons.star_border_rounded, size: 18),
      ),
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
    return Row(
      children: [
        IconButton(
          onPressed: canDelete ? onDelete : null,
          icon: Icon(
            Icons.close_rounded,
            color: canDelete ? Colors.grey.shade500 : Colors.grey.shade300,
          ),
        ),
        Expanded(
          child: CustomFormTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: CustomTextFieldType.text,
            hintText: 'اكتب خيار',
            controller: answer.answerController,
            textDirection: TextDirection.rtl,
          ),
        ),
        const SizedBox(width: 12),
        ScoreInput(controller: answer.scoreController),
      ],
    );
  }
}

class QuestionnaireBody extends StatefulWidget {
  const QuestionnaireBody({
    super.key,
    required this.questionIndex,
    required this.canDeleteQuestion,
    required this.onDeleteQuestion,
  });

  final int questionIndex;
  final bool canDeleteQuestion;
  final VoidCallback onDeleteQuestion;

  @override
  State<QuestionnaireBody> createState() => QuestionnaireBodyState();
}

class QuestionnaireBodyState extends State<QuestionnaireBody> {
  QuestionType questionType = QuestionType.multiple;
  final TextEditingController questionController = TextEditingController();

  final List<AnswerItemModel> answers = [AnswerItemModel(), AnswerItemModel()];
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
      answers[index].dispose();
      answers.removeAt(index);
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
    return Directionality(
      textDirection: TextDirection.rtl,
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
          children: [
            Row(
              children: [
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
              ],
            ),
            const SizedBox(height: 25),
            LabeledInput(
              w: w,
              label: 'نص السؤال',
              hint: 'اكتب السؤال هنا',
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
                        onAnimationEnd: () => deleteAnswerAfterAnimation(index),
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
            AddOutlineButton(title: 'إضافة خيار', onPressed: addAnswer),
          ],
        ),
      ),
    );
  }
}

class NumberInput extends StatelessWidget {
  const NumberInput({super.key, required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: surveyPurple),
        ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(.2)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: canDelete ? onDelete : null,
            icon: Icon(
              Icons.delete_outline_rounded,
              color: canDelete ? surveyPink : Colors.grey.shade300,
            ),
          ),
          Expanded(
            child: CustomFormTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: CustomTextFieldType.score,
              labelText: "من",
              centerHint: true,
              hintText: '0',
              controller: item.fromController,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomFormTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: CustomTextFieldType.score,
              labelText: "إلى",
              centerHint: true,
              hintText: '100',
              controller: item.toController,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: CustomFormTextField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: CustomTextFieldType.diagnose,
              hintText: 'اكتب التشخيص',
              controller: item.diagnosisController,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
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
    return Directionality(
      textDirection: TextDirection.rtl,
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
          children: [
            customText(
              text: 'إعداد التشخيص الكلي للفورم',
              color: Colors.deepPurple[400],
              bold: true,
              size: w * 0.011,
            ),
            const SizedBox(height: 6),
            customText(
              text: 'يمكنك تحديد تشخيص لكل نطاق من السكور الكلي',
              color: Colors.deepPurple[300],
              size: w * 0.009,
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
            AddOutlineButton(
              title: 'إضافة تشخيص جديد',
              color: surveyPurple,
              onPressed: addDiagnosis,
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionnairePageHeader extends StatelessWidget {
  const QuestionnairePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return Column(
      children: [
        Icon(Icons.assignment_add, size: w * 0.04, color: Colors.pink),
        const SizedBox(height: 8),
        customText(
          text: 'إنشاء استبيان جديد',
          color: surveyDark,
          size: w * 0.013,
        ),
        const SizedBox(height: 7),
        customText(
          text: 'قم بإضافة الأسئلة والإجابات',
          color: Colors.grey.shade500,
          size: w * 0.009,
        ),
      ],
    );
  }
}

class SurveyTitleCard extends StatelessWidget {
  const SurveyTitleCard({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    return Directionality(
      textDirection: TextDirection.rtl,
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
        ),
      ),
    );
  }
}

Widget scoreCounter({
  required double width,
  required double h,
  required double height,
  required TextEditingController controller,
}) {
  final FocusNode focusNode = FocusNode();

  focusNode.addListener(() {
    if (!focusNode.hasFocus) {
      if (controller.text.trim().isEmpty) {
        controller.text = "0";
      }
    }
  });

  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(
        fontFamily: 'ArabicCustomFont',
        fontWeight: FontWeight.bold,
        fontSize: h * 0.02,
      ),
    ),
  );
}
