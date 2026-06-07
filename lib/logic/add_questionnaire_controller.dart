import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/widgets/questionnaire_body.dart';
import 'package:flutter/material.dart';

class AddQuestionnaireController extends ChangeNotifier {
  static const int maxQuestions = 20;

  final AppRepository formRepository = AppRepository();
  final TextEditingController surveyTitleController = TextEditingController();

  final GlobalKey<DiagnosisSectionState> diagnosisKey =
      GlobalKey<DiagnosisSectionState>();

  bool isSaving = false;
  bool isLoadingForms = false;
  bool isEditMode = false;

  String? editingFormId;

  List<Map<String, dynamic>> availableForms = [];

  final List<QuestionItem> questions = [
    QuestionItem(id: 1, key: GlobalKey<QuestionnaireBodyState>()),
    QuestionItem(id: 2, key: GlobalKey<QuestionnaireBodyState>()),
  ];

  @override
  void dispose() {
    surveyTitleController.dispose();
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
    } catch (e) {
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

  String? validateBeforeSave() {
    final title = surveyTitleController.text.trim();

    if (title.isEmpty) {
      return 'اكتب عنوان الاستبيان أولاً.';
    }

    if (questions.isEmpty) {
      return 'يجب إضافة سؤال واحد على الأقل.';
    }

    if (questions.length < 2) {
      return 'يجب أن يحتوي الاستبيان على سؤالين على الأقل حتى يكون التشخيص أدق.';
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

      if (question.answers.length < 2) {
        return 'السؤال رقم ${i + 1} يجب أن يحتوي على إجابتين على الأقل.';
      }

      final scores = <int>[];

      for (int j = 0; j < question.answers.length; j++) {
        final answer = question.answers[j];

        if (answer.answerText.trim().isEmpty) {
          return 'اكتب نص الإجابة رقم ${j + 1} في السؤال رقم ${i + 1}.';
        }

        if (answer.score < 0 || answer.score > 100) {
          return 'سكور الإجابة رقم ${j + 1} في السؤال رقم ${i + 1} يجب أن يكون من 0 إلى 100.';
        }

        scores.add(answer.score);
      }

      final int questionMinScore = _minScore(scores);

      final int questionMaxScore = question.questionType == QuestionType.single
          ? _maxScore(scores)
          : scores.fold<int>(0, (sum, score) => sum + score);

      formMinScore += questionMinScore;
      formMaxScore += questionMaxScore;
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

      if (range.diagnosis.trim().isEmpty) {
        return 'اكتب اسم التشخيص رقم ${i + 1}.';
      }

      if (range.from > range.to) {
        return 'في التشخيص رقم ${i + 1}، قيمة "من" يجب أن تكون أقل من أو تساوي "إلى".';
      }
    }

    ranges.sort((a, b) => a.from.compareTo(b.from));

    if (ranges.first.from != formMinScore) {
      return 'أول تشخيص يجب أن يبدأ من $formMinScore حسب أقل سكور ممكن للفورم.';
    }

    if (ranges.last.to != formMaxScore) {
      return 'آخر تشخيص يجب أن ينتهي عند $formMaxScore حسب أعلى سكور ممكن للفورم.';
    }

    for (int i = 0; i < ranges.length - 1; i++) {
      final current = ranges[i];
      final next = ranges[i + 1];

      if (current.to >= next.from) {
        return 'يوجد تداخل بين التشخيص "${current.diagnosis}" و "${next.diagnosis}".';
      }

      if (current.to + 1 != next.from) {
        return 'يوجد فراغ في التشخيص بين ${current.to} و ${next.from}.';
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

      questionsBody.add({
        "order": i + 1,
        "text": question.questionText,
        "type": question.questionType == QuestionType.single
            ? "SINGLE_SELECT"
            : "MULTI_SELECT",
        "required": true,
        "choices": List.generate(question.answers.length, (answerIndex) {
          final answer = question.answers[answerIndex];

          return {
            "order": answerIndex + 1,
            "label": answer.answerText,
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
        "label": range.diagnosis,
        "minScore": range.from,
        "maxScore": range.to,
      };
    }).toList();
  }

  Future<void> saveSurvey(BuildContext context) async {
    final error = validateBeforeSave();

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
      final questionsBody = buildQuestionsBody();
      final scoreRangesBody = buildScoreRangesBody();

      if (isEditMode && editingFormId != null) {
        final body = {
          "key": surveyTitleController.text.trim().toUpperCase().replaceAll(
            ' ',
            '_',
          ),
          "name": surveyTitleController.text.trim(),
          "scoringType": "SUM",
          "interpretationMode": "RANGE",
          "questions": questionsBody,
          "scoreRanges": scoreRangesBody,
        };

        await formRepository.updateFormRaw(formId: editingFormId!, body: body);
      } else {
        await formRepository.createForm(
          formName: surveyTitleController.text.trim(),
          questions: questionsBody,
          diagnoses: scoreRangesBody,
        );
      }

      if (!context.mounted) return;

      await loadAvailableForms(context);

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
        message: 'حدث خطأ أثناء حفظ الاستبيان، حاول مرة أخرى.',
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
      final currentVersion = json["currentVersion"] ?? {};
      final apiQuestions = currentVersion["questions"] as List? ?? [];
      final apiRanges = currentVersion["scoreRanges"] as List? ?? [];

      isEditMode = true;
      editingFormId = formId;
      surveyTitleController.text = formName;

      questions.clear();

      for (int i = 0; i < apiQuestions.length; i++) {
        questions.add(
          QuestionItem(
            id: DateTime.now().millisecondsSinceEpoch + i,
            key: GlobalKey<QuestionnaireBodyState>(),
            initialData: apiQuestions[i],
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
        message: 'تم تحميل الاستبيان للتعديل. لا يمكن تعديل عنوان الاستبيان.',
        isInfo: true,
      );
    } catch (e) {
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
      await loadAvailableForms(context);

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
    } catch (e) {
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
    surveyTitleController.clear();

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
