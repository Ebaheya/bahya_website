import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body_widgets.dart';
import 'package:flutter/material.dart';

part 'add_questionnaire_payloads.dart';

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
