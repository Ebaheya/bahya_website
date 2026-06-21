import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body_widgets.dart';
import 'package:flutter/material.dart';

class AddQuestionnaireController extends ChangeNotifier {
  static const int maxQuestions = 20;

  final AppRepository formRepository = AppRepository();

  final TextEditingController formKeyController = TextEditingController();
  final TextEditingController surveyTitleController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final TextEditingController scoringTypeController = TextEditingController(
    text: 'SUM',
  );

  final TextEditingController interpretationModeController =
      TextEditingController(text: 'RANGE');

  final GlobalKey<DiagnosisSectionState> diagnosisKey =
      GlobalKey<DiagnosisSectionState>();

  bool isSaving = false;
  bool isLoadingForms = false;
  bool isEditMode = false;

  String? editingFormId;
  String? editingFormKey;

  List<Map<String, dynamic>> availableForms = [];

  final List<QuestionItem> questions = [
    QuestionItem(id: 1, key: GlobalKey<QuestionnaireBodyState>()),
    QuestionItem(id: 2, key: GlobalKey<QuestionnaireBodyState>()),
  ];

  AddQuestionnaireController() {
    surveyTitleController.addListener(() {
      if (isEditMode) return;
      formKeyController.text = '';
    });
  }

  String get saveButtonText => isEditMode ? 'تعديل الاستبيان' : 'حفظ الاستبيان';

  String get editorModeText =>
      isEditMode ? 'أنت الآن في وضع تعديل استبيان موجود' : 'إنشاء استبيان جديد';

  @override
  void dispose() {
    formKeyController.dispose();
    surveyTitleController.dispose();
    categoryController.dispose();
    scoringTypeController.dispose();
    interpretationModeController.dispose();
    super.dispose();
  }

  Future<void> loadAvailableForms(BuildContext context) async {
    isLoadingForms = true;
    notifyListeners();

    try {
      final response = await formRepository.getForms();

      availableForms = response.data.map((form) {
        return {"id": form.id, "name": form.name, "key": form.key};
      }).toList();
    } catch (_) {
      if (!context.mounted) return;

      customDialog(
        context: context,
        title: 'خطأ',
        message: 'حدث خطأ أثناء تحميل النماذج.',
        isError: true,
      );
    } finally {
      isLoadingForms = false;
      notifyListeners();
    }
  }

  void addQuestion(BuildContext context) {
    if (questions.length >= maxQuestions) {
      customDialog(
        context: context,
        title: 'تنبيه',
        message:
            'لا يمكن إضافة أكثر من $maxQuestions سؤالاً في الاستبيان الواحد.',
        isInfo: true,
      );
      return;
    }

    questions.add(
      QuestionItem(
        id: DateTime.now().millisecondsSinceEpoch,
        key: GlobalKey<QuestionnaireBodyState>(),
      ),
    );

    notifyListeners();
  }

  void removeQuestion(BuildContext context, int index) {
    if (questions.length == 1) {
      customDialog(
        context: context,
        title: 'تنبيه',
        message: 'يجب أن يحتوي الاستبيان على سؤال واحد على الأقل.',
        isInfo: true,
      );
      return;
    }

    questions[index].isDeleting = true;
    notifyListeners();
  }

  void deleteQuestionAfterAnimation(int index) {
    if (index < 0 || index >= questions.length) return;

    questions.removeAt(index);
    notifyListeners();
  }

  int _minScore(List<int> scores) {
    return scores.reduce((a, b) => a < b ? a : b);
  }

  int _maxScore(List<int> scores) {
    return scores.reduce((a, b) => a > b ? a : b);
  }

  String _buildCategory() {
    final category = categoryController.text.trim();

    if (category.isNotEmpty) return category;

    return 'general';
  }

  String _readableError(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '').trim();

    if (text.contains('FORM_SCALE_HAS_CHOICES')) {
      return 'سؤال Scale لا يجب أن يحتوي على choices.';
    }

    if (text.contains('Unrecognized key')) {
      return 'البيانات المرسلة تحتوي حقول غير مدعومة من السيرفر.';
    }

    if (text.contains('FORM_KEY_INVALID')) {
      return 'مشكلة في form key. حاول إنشاء الاستبيان من جديد.';
    }

    if (text.contains('String must contain at least 2 character')) {
      return 'اسم الاستبيان يجب أن يكون حرفين على الأقل.';
    }

    if (text.contains('category')) {
      return 'يجب تحديد تصنيف الاستبيان.';
    }

    if (text.isEmpty) return 'حدث خطأ غير متوقع.';

    return text;
  }

  String? validateFormForSubmit() {
    final formName = surveyTitleController.text.trim();
    final category = _buildCategory();

    if (formName.isEmpty) return 'اكتب اسم الاستبيان أولاً.';

    if (formName.length < 2) {
      return 'اسم الاستبيان يجب أن يكون حرفين على الأقل.';
    }

    if (isEditMode && (editingFormKey == null || editingFormKey!.isEmpty)) {
      return 'لا يمكن تعديل الاستبيان لأن key القديم غير موجود.';
    }

    if (category.isEmpty) {
      return 'اكتب category / التشخيص قبل الحفظ.';
    }

    if (questions.isEmpty) {
      return 'يجب إضافة سؤال واحد على الأقل.';
    }

    int formMinScore = 0;
    int formMaxScore = 0;

    for (int i = 0; i < questions.length; i++) {
      final state = questions[i].key.currentState;

      if (state == null) {
        return 'حدث خطأ أثناء قراءة بيانات السؤال ${i + 1}.';
      }

      final question = state.getQuestionData();

      if (question.questionText.trim().isEmpty) {
        return 'اكتب نص السؤال رقم ${i + 1}.';
      }

      if (question.questionType == QuestionType.scale) {
        final minValue = question.minValue;
        final maxValue = question.maxValue;

        if (minValue == null || maxValue == null) {
          return 'سؤال Scale رقم ${i + 1} يجب أن يحتوي minValue و maxValue.';
        }

        if (maxValue <= minValue) {
          return 'في سؤال Scale رقم ${i + 1}، maxValue يجب أن يكون أكبر من minValue.';
        }

        if ((maxValue - minValue) > 20) {
          return 'سؤال Scale رقم ${i + 1} لا يمكن أن يزيد عن 20 درجة.';
        }

        formMinScore += minValue;
        formMaxScore += maxValue;
        continue;
      }

      if (question.answers.length < 2) {
        return 'السؤال رقم ${i + 1} يجب أن يحتوي على اختيارين على الأقل.';
      }

      final scores = <int>[];

      for (int j = 0; j < question.answers.length; j++) {
        final answer = question.answers[j];
        final scoreText = state.answers[j].scoreController.text.trim();

        if (answer.answerText.trim().isEmpty) {
          return 'اكتب label الاختيار رقم ${j + 1} في السؤال رقم ${i + 1}.';
        }

        final score = int.tryParse(scoreText);

        if (scoreText.isEmpty || score == null) {
          return 'score الاختيار رقم ${j + 1} في السؤال رقم ${i + 1} يجب أن يكون رقم.';
        }

        if (score < 0 || score > 100) {
          return 'score الاختيار رقم ${j + 1} في السؤال رقم ${i + 1} يجب أن يكون من 0 إلى 100.';
        }

        scores.add(score);
      }

      formMinScore += _minScore(scores);
      formMaxScore += question.questionType == QuestionType.single
          ? _maxScore(scores)
          : scores.fold<int>(0, (sum, score) => sum + score);
    }

    final diagnosisState = diagnosisKey.currentState;

    if (diagnosisState == null) {
      return 'حدث خطأ أثناء قراءة بيانات التشخيص.';
    }

    final ranges = diagnosisState.getDiagnosisRanges();

    if (ranges.isEmpty) {
      return 'يجب إضافة تشخيص واحد على الأقل.';
    }

    for (int i = 0; i < ranges.length; i++) {
      final range = ranges[i];
      final item = diagnosisState.diagnosisItems[i];

      if (range.diagnosis.trim().isEmpty) {
        return 'اكتب اسم التشخيص رقم ${i + 1}.';
      }

      final fromText = item.fromController.text.trim();
      final toText = item.toController.text.trim();

      if (fromText.isEmpty ||
          toText.isEmpty ||
          int.tryParse(fromText) == null ||
          int.tryParse(toText) == null) {
        return 'minScore و maxScore في التشخيص رقم ${i + 1} يجب أن يكونا أرقام.';
      }

      if (range.from > range.to) {
        return 'في التشخيص رقم ${i + 1}، maxScore يجب أن يكون أكبر من أو يساوي minScore.';
      }
    }

    ranges.sort((a, b) => a.from.compareTo(b.from));

    if (ranges.first.from != formMinScore) {
      return 'أول range يجب أن يبدأ من $formMinScore حسب أقل score ممكن للفورم.';
    }

    if (ranges.last.to != formMaxScore) {
      return 'آخر range يجب أن ينتهي عند $formMaxScore حسب أعلى score ممكن للفورم.';
    }

    for (int i = 0; i < ranges.length - 1; i++) {
      final current = ranges[i];
      final next = ranges[i + 1];

      if (current.to >= next.from) {
        return 'يوجد overlap بين "${current.diagnosis}" و "${next.diagnosis}".';
      }

      if (current.to + 1 != next.from) {
        return 'يوجد gap بين ranges من ${current.to + 1} إلى ${next.from - 1}.';
      }
    }

    return null;
  }

  List<Map<String, dynamic>> buildQuestionsBody() {
    final questionsBody = <Map<String, dynamic>>[];

    for (int i = 0; i < questions.length; i++) {
      final state = questions[i].key.currentState;

      if (state == null) continue;

      final question = state.getQuestionData();

      if (question.questionType == QuestionType.scale) {
        final minValue = question.minValue ?? 0;
        final maxValue = question.maxValue ?? 10;

        questionsBody.add({
          "order": i + 1,
          "text": question.questionText.trim(),
          "type": QuestionType.scale.apiValue,
          "subscale": null,
          "required": true,
          "scaleMin": minValue,
          "scaleMax": maxValue,
          "scaleStep": 1,
        });

        continue;
      }

      questionsBody.add({
        "order": i + 1,
        "text": question.questionText.trim(),
        "type": question.questionType.apiValue,
        "subscale": null,
        "required": true,
        "choices": List.generate(question.answers.length, (answerIndex) {
          final answer = question.answers[answerIndex];

          return {
            "order": answerIndex + 1,
            "label": answer.answerText.trim(),
            "score": answer.score,
          };
        }),
      });
    }

    return questionsBody;
  }

  List<Map<String, dynamic>> buildScoreRangesBody() {
    final diagnosisState = diagnosisKey.currentState;

    if (diagnosisState == null) return [];

    final ranges = diagnosisState.getDiagnosisRanges();

    return ranges.map((range) {
      return {
        "subscale": null,
        "label": range.diagnosis.trim(),
        "minScore": range.from,
        "maxScore": range.to,
      };
    }).toList();
  }

Map<String, dynamic> buildFormBody() {
    final body = <String, dynamic>{
      "name": surveyTitleController.text.trim(),
      "category": _buildCategory(),
      "scoringType": scoringTypeController.text.trim().isEmpty
          ? "SUM"
          : scoringTypeController.text.trim(),
      "interpretationMode": interpretationModeController.text.trim().isEmpty
          ? "RANGE"
          : interpretationModeController.text.trim(),
      "questions": buildQuestionsBody(),
      "scoreRanges": buildScoreRangesBody(),
    };

    if (isEditMode && editingFormKey != null && editingFormKey!.isNotEmpty) {
      body["key"] = editingFormKey;
    }

    return body;
  }

  Future<void> saveSurvey(BuildContext context) async {
    final error = validateFormForSubmit();

    if (error != null) {
      customDialog(
        context: context,
        title: 'تنبيه',
        message: error,
        isError: true,
      );
      return;
    }

    if (isSaving) return;

    isSaving = true;
    notifyListeners();

    try {
      final body = buildFormBody();

      if (isEditMode && editingFormId != null) {
        await formRepository.updateFormRaw(formId: editingFormId!, body: body);
      } else {
        await formRepository.createFormRaw(body: body);
      }

      if (!context.mounted) return;

      await loadAvailableForms(context);

      if (!context.mounted) return;

      customDialog(
        context: context,
        title: isEditMode ? 'تم التعديل' : 'تم الحفظ',
        message: isEditMode
            ? 'تم تعديل الاستبيان بنجاح.'
            : 'تم حفظ الاستبيان بنجاح.',
        isSuccess: true,
      );

      resetEditor();
    } catch (e) {
      if (!context.mounted) return;

      customDialog(
        context: context,
        title: 'خطأ',
        message: _readableError(e),
        isError: true,
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> editForm(BuildContext context, String formId) async {
    try {
      final json = await formRepository.getFormByIdRaw(formId);

      final formName = json["name"]?.toString() ?? "";
      final formKey = json["key"]?.toString() ?? "";

      final currentVersion = json["currentVersion"] ?? {};
      final apiQuestions = currentVersion["questions"] as List? ?? [];
      final apiRanges = currentVersion["scoreRanges"] as List? ?? [];

      isEditMode = true;
      editingFormId = formId;
      editingFormKey = formKey;

      surveyTitleController.text = formName;
      formKeyController.text = formKey;
      categoryController.text = json["category"]?.toString() ?? "general";
      scoringTypeController.text = json["scoringType"]?.toString() ?? "SUM";
      interpretationModeController.text =
          json["interpretationMode"]?.toString() ?? "RANGE";

      questions.clear();

      for (int i = 0; i < apiQuestions.length; i++) {
        questions.add(
          QuestionItem(
            id: DateTime.now().millisecondsSinceEpoch + i,
            key: GlobalKey<QuestionnaireBodyState>(),
            initialData: Map<String, dynamic>.from(apiQuestions[i]),
          ),
        );
      }

      while (questions.length < 2) {
        questions.add(
          QuestionItem(
            id: DateTime.now().millisecondsSinceEpoch + questions.length,
            key: GlobalKey<QuestionnaireBodyState>(),
          ),
        );
      }

      diagnosisKey.currentState?.setDiagnosisRangesFromApi(apiRanges);

      notifyListeners();

      if (!context.mounted) return;

      customDialog(
        context: context,
        title: 'وضع التعديل',
        message: 'تم تحميل الاستبيان للتعديل.',
        isInfo: true,
      );
    } catch (_) {
      if (!context.mounted) return;

      customDialog(
        context: context,
        title: 'خطأ',
        message: 'حدث خطأ أثناء تحميل الاستبيان للتعديل.',
        isError: true,
      );
    }
  }

  Future<void> deleteForm(BuildContext context, String formId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: customText(
            text: 'حذف الاستبيان',
            size: 18,
            color: Colors.black87,
            isCenter: false,
          ),
          content: customText(
            text: 'هل أنت متأكد من حذف هذا الاستبيان؟',
            size: 16,
            color: Colors.black87,
            isCenter: false,
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: customText(text: 'إلغاء', size: 14, color: Colors.pink),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: customText(text: 'حذف', size: 14, color: Colors.red),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await formRepository.deleteForm(formId: formId);

      if (!context.mounted) return;

      await loadAvailableForms(context);

      if (!context.mounted) return;

      if (editingFormId == formId) {
        resetEditor();
      }

      if (!context.mounted) return;

      customDialog(
        context: context,
        title: 'تم الحذف',
        message: 'تم حذف الاستبيان بنجاح.',
        isSuccess: true,
      );
    } catch (_) {
      if (!context.mounted) return;

      customDialog(
        context: context,
        title: 'خطأ',
        message: 'حدث خطأ أثناء حذف الاستبيان.',
        isError: true,
      );
    }
  }

  void resetEditor() {
    isEditMode = false;
    editingFormId = null;
    editingFormKey = null;

    formKeyController.clear();
    surveyTitleController.clear();
    categoryController.clear();
    scoringTypeController.text = "SUM";
    interpretationModeController.text = "RANGE";

    questions.clear();

    final now = DateTime.now().millisecondsSinceEpoch;

    questions.addAll([
      QuestionItem(id: now, key: GlobalKey<QuestionnaireBodyState>()),
      QuestionItem(id: now + 1, key: GlobalKey<QuestionnaireBodyState>()),
    ]);

    diagnosisKey.currentState?.resetRanges();

    notifyListeners();
  }
}
