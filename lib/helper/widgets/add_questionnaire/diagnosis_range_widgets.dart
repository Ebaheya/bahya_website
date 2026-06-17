part of 'questionnaire_body_widgets.dart';

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
