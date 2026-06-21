part of 'questionnaire_body_widgets.dart';

class QuestionnairePageHeader extends StatelessWidget {
  const QuestionnairePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.black.withValues(alpha: .08),
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
