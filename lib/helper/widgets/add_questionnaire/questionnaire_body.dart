import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum QuestionType { single, multiple }

const Color surveyPink = Color(0xFFFF4F93);
const Color surveyPurple = Color(0xFF8E3FD1);
const Color surveyDark = Color(0xFF3B1038);
const Color surveyCard = Color(0xFFFFFBFE);

bool isEnglishLang(Locale locale) => locale.languageCode == 'en';

TextDirection appTextDirection(bool isEnglish) {
  return isEnglish ? TextDirection.ltr : TextDirection.rtl;
}

CrossAxisAlignment appCrossAxisAlignment(bool isEnglish) {
  return isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end;
}

TextAlign appTextAlign(bool isEnglish) {
  return isEnglish ? TextAlign.start : TextAlign.end;
}

class AnswerItemModel {
  final TextEditingController answerController;
  final TextEditingController scoreController;
  bool isDeleting;

  AnswerItemModel({
    String answer = '',
    String score = '0',
    this.isDeleting = false,
  }) : answerController = TextEditingController(text: answer),
       scoreController = TextEditingController(text: score);

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
  final TextEditingController fromController;
  final TextEditingController toController;
  final TextEditingController diagnosisController;
  bool isDeleting;

  DiagnosisItemModel({
    String from = '0',
    String to = '100',
    String diagnosis = '',
    this.isDeleting = false,
  }) : fromController = TextEditingController(text: from),
       toController = TextEditingController(text: to),
       diagnosisController = TextEditingController(text: diagnosis);

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

class _AnimatedRemoveState extends State<AnimatedRemove>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> fadeAnimation;
  late final Animation<double> sizeAnimation;
  late final Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    sizeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.04),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward().whenComplete(widget.onAnimationEnd);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: sizeAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: slideAnimation, child: widget.child),
      ),
    );
  }
}

Widget sectionLabel({
  required String label,
  required IconData? icon,
  required double w,
}) {
  return ValueListenableBuilder<Locale>(
    valueListenable: AppLanguageController.localeNotifier,
    builder: (context, locale, _) {
      final isEnglish = isEnglishLang(locale);

      return Row(
        textDirection: TextDirection.ltr,
        mainAxisAlignment: isEnglish
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isEnglish) ...[
            if (icon != null) ...[
              Icon(icon, color: surveyPurple, size: w * 0.012),
              const SizedBox(width: 10),
            ],
          ],
          Flexible(
            child: customText(
              text: label,
              color: surveyDark,
              bold: true,
              size: w * 0.01,
              isCenter: false,
              align: isEnglish ? TextAlign.end : TextAlign.start,
              isEnglish: isEnglish,
            ),
          ),
          if (!isEnglish) ...[
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, color: surveyPurple, size: w * 0.012),
            ],
          ],
        ],
      );
    },
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
    this.isEditing = true,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final int maxLines;
  final double w;
  final bool isTitle;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Column(
          crossAxisAlignment: appCrossAxisAlignment(isEnglish),
          children: [
            sectionLabel(label: label, icon: icon, w: w),
            const SizedBox(height: 8),
            Directionality(
              textDirection: appTextDirection(isEnglish),
              child: CustomFormTextField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: CustomTextFieldType.text,
                hintText: localizedText(context, hint),
                controller: controller,
                readOnly: !isEditing,
                textDirection: appTextDirection(isEnglish),
                maxLines: maxLines,
              ),
            ),
          ],
        );
      },
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
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = isEnglishLang(locale);

        return Directionality(
          textDirection: appTextDirection(isEnglish),
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add_rounded),
            label: Text(localizedText(context, title)),
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color.withOpacity(.65)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              textStyle: const TextStyle(
                fontFamily: 'ArabicCustomFont',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
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
        hintText: localizedText(context, '0'),
        prefixIcon: const Icon(Icons.star_border_rounded, size: 18),
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
