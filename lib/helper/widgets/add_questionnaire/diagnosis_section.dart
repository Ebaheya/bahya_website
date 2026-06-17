part of 'questionnaire_body_widgets.dart';

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
