part of 'questionnaire_body_widgets.dart';

class DiagnosisSection extends StatefulWidget {
  final ScoreBounds Function()? scoreBoundsBuilder;

  const DiagnosisSection({super.key, this.scoreBoundsBuilder});

  @override
  State<DiagnosisSection> createState() => DiagnosisSectionState();
}

class DiagnosisSectionState extends State<DiagnosisSection> {
  static const int minimumDiagnosisRangeSize = 5;

  final List<DiagnosisItemModel> diagnosisItems = [
    DiagnosisItemModel(from: '0', to: '50'),
    DiagnosisItemModel(from: '51', to: '100'),
  ];

  ScoreBounds _currentBounds() {
    return widget.scoreBoundsBuilder?.call() ??
        const ScoreBounds(minScore: 0, maxScore: 100);
  }

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

    if (diagnosisItems.length < 2) {
      _resetItemsWithAutoRanges(diagnosisCount: 2);
    }

    setState(() {});
  }

  void resetRanges() {
    for (final item in diagnosisItems) {
      item.dispose();
    }

    diagnosisItems.clear();
    _resetItemsWithAutoRanges(diagnosisCount: 2);

    setState(() {});
  }

  @override
  void dispose() {
    for (final item in diagnosisItems) {
      item.dispose();
    }

    super.dispose();
  }

  bool _canSplitIntoCount(int diagnosisCount) {
    final bounds = _currentBounds();

    if (bounds.maxScore < bounds.minScore) return false;

    return bounds.totalValues >= diagnosisCount * minimumDiagnosisRangeSize;
  }

  List<DiagnosisRangeValidationData> _generateAutoRanges({
    required int diagnosisCount,
  }) {
    final bounds = _currentBounds();
    final totalValues = bounds.totalValues;
    final baseSize = totalValues ~/ diagnosisCount;
    final remainder = totalValues % diagnosisCount;
    final ranges = <DiagnosisRangeValidationData>[];

    int start = bounds.minScore;

    for (int i = 0; i < diagnosisCount; i++) {
      final currentSize = baseSize + (i < remainder ? 1 : 0);
      final end = start + currentSize - 1;

      ranges.add(
        DiagnosisRangeValidationData(
          from: start,
          to: end,
          diagnosis: i < diagnosisItems.length
              ? diagnosisItems[i].diagnosisController.text.trim()
              : '',
        ),
      );

      start = end + 1;
    }

    return ranges;
  }

  void _resetItemsWithAutoRanges({required int diagnosisCount}) {
    final ranges = _generateAutoRanges(diagnosisCount: diagnosisCount);

    diagnosisItems.clear();

    for (final range in ranges) {
      diagnosisItems.add(
        DiagnosisItemModel(
          from: range.from.toString(),
          to: range.to.toString(),
          diagnosis: range.diagnosis,
        ),
      );
    }
  }

  void _applyAutoRanges({required int diagnosisCount}) {
    final ranges = _generateAutoRanges(diagnosisCount: diagnosisCount);

    while (diagnosisItems.length < diagnosisCount) {
      diagnosisItems.add(DiagnosisItemModel());
    }

    while (diagnosisItems.length > diagnosisCount) {
      final removed = diagnosisItems.removeLast();
      removed.dispose();
    }

    for (int i = 0; i < ranges.length; i++) {
      diagnosisItems[i].isDeleting = false;
      diagnosisItems[i].fromController.text = ranges[i].from.toString();
      diagnosisItems[i].toController.text = ranges[i].to.toString();
    }
  }

  void syncRangesWithAnswerScores() {
    if (!mounted) return;

    final currentCount = diagnosisItems.length < 2 ? 2 : diagnosisItems.length;
    var targetCount = currentCount;

    while (targetCount > 2 && !_canSplitIntoCount(targetCount)) {
      targetCount--;
    }

    setState(() {
      _applyAutoRanges(diagnosisCount: targetCount);
    });
  }

  void addDiagnosis() {
    final nextCount = diagnosisItems.length + 1;

    if (!_canSplitIntoCount(nextCount)) {
         final bounds = _currentBounds();
      final maxCount = bounds.totalValues ~/ minimumDiagnosisRangeSize;
      customDialog(
        title: 'لا يمكن إضافة تشخيص جديد',
        message:    'لا يمكن إضافة تشخيص جديد. أقل مدى لكل تشخيص هو $minimumDiagnosisRangeSize درجات، وأقصى عدد مناسب حالياً هو ${maxCount < 2 ? 2 : maxCount}.',
        isInfo: true,
        context: context,
      );
      return;
    }

    setState(() {
      _applyAutoRanges(diagnosisCount: nextCount);
    });
  }

  void removeDiagnosis(int index) {
    if (diagnosisItems.length <= 2) return;

    setState(() {
      diagnosisItems[index].isDeleting = true;
    });
  }

  void deleteDiagnosisAfterAnimation(int index) {
    if (index < 0 || index >= diagnosisItems.length) return;

    final removedItem = diagnosisItems[index];

    setState(() {
      diagnosisItems.removeAt(index);
      removedItem.dispose();

      if (_canSplitIntoCount(diagnosisItems.length)) {
        _applyAutoRanges(diagnosisCount: diagnosisItems.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final isMobile = w < 700;
    final bounds = _currentBounds();

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
                  color: Colors.black.withValues(alpha: .08),
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
                    text:
                        'يتم تقسيم السكور تلقائياً ويمكن للطبيب تعديل الرينجات يدوياً',
                    color: Colors.deepPurple[300],
                    size: responsiveSize(context, 0.009, min: 12, max: 16),
                    isEnglish: isEnglish,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: customText(
                    text:
                        'أقل score: ${bounds.minScore}  |  أكبر score: ${bounds.maxScore}  |  أقل مدى للتشخيص: $minimumDiagnosisRangeSize',
                    color: surveyDark.withValues(alpha: .72),
                    size: responsiveSize(context, 0.008, min: 11, max: 13),
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
                              canDelete: diagnosisItems.length > 2,
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
