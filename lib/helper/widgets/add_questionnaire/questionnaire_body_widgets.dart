import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
part 'questionnaire_body_editor.dart';
part 'diagnosis_range_widgets.dart';
part 'diagnosis_section.dart';
part 'questionnaire_header_widgets.dart';

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
              color: isSelected
                  ? surveyPurple.withValues(alpha: .07)
                  : Colors.white,
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
                      ? surveyPurple.withValues(alpha: .12)
                      : Colors.black.withValues(alpha: .035),
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
            ? surveyPurple.withValues(alpha: .12)
            : surveyPink.withValues(alpha: .08),
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
              border: Border.all(color: surveyPink.withValues(alpha: .18)),
              boxShadow: [
                BoxShadow(
                  color: surveyPink.withValues(alpha: .055),
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
              borderSide: BorderSide(color: surveyPink.withValues(alpha: .55)),
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
              borderSide: BorderSide(
                color: surveyPurple.withValues(alpha: .45),
              ),
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
            ? surveyPink.withValues(alpha: .08)
            : Colors.grey.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.01, min: 12, max: 15),
        ),
        border: Border.all(
          color: canDelete
              ? surveyPink.withValues(alpha: .25)
              : Colors.grey.withValues(alpha: .15),
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
