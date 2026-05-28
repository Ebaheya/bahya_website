import 'package:bahya_website/data/api/repo/repo.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/questionnaire_body.dart';
import 'package:flutter/material.dart';

class AddQuestionnaire extends StatefulWidget {
  const AddQuestionnaire({super.key});

  @override
  State<AddQuestionnaire> createState() => _AddQuestionnaireState();
}

class _AddQuestionnaireState extends State<AddQuestionnaire> {
  static const int maxQuestions = 20;

  final AppRepository formRepository = AppRepository();
  final TextEditingController surveyTitleController = TextEditingController();

  bool isSaving = false;
  bool isLoadingForms = false;
  bool isEditMode = false;

  String? editingFormId;

  List<Map<String, dynamic>> availableForms = [];

  final List<QuestionItem> questions = [
    QuestionItem(
      id: DateTime.now().millisecondsSinceEpoch,
      key: GlobalKey<QuestionnaireBodyState>(),
    ),
  ];

  final GlobalKey<DiagnosisSectionState> diagnosisKey =
      GlobalKey<DiagnosisSectionState>();

  @override
  void initState() {
    super.initState();
    loadAvailableForms();
  }

  @override
  void dispose() {
    surveyTitleController.dispose();
    super.dispose();
  }

  Future<void> loadAvailableForms() async {
    setState(() => isLoadingForms = true);

    try {
      final response = await formRepository.getForms();

      availableForms = response.data.map((form) {
        return {"id": form.id, "name": form.name, "key": form.key};
      }).toList();
    } catch (e) {
      if (!mounted) return;

      customDialog(
        context: context,
        title: 'خطأ',
        message: 'حدث خطأ أثناء تحميل النماذج.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoadingForms = false);
      }
    }
  }

  void addQuestion() {
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

    setState(() {
      questions.add(
        QuestionItem(
          id: DateTime.now().millisecondsSinceEpoch,
          key: GlobalKey<QuestionnaireBodyState>(),
        ),
      );
    });
  }

  void removeQuestion(int index) {
    if (questions.length == 1) {
      customDialog(
        context: context,
        title: 'تنبيه',
        message: 'يجب أن يحتوي الاستبيان على سؤال واحد على الأقل.',
        isInfo: true,
      );
      return;
    }

    setState(() {
      questions[index].isDeleting = true;
    });
  }

  void deleteQuestionAfterAnimation(int index) {
    if (index < 0 || index >= questions.length) return;

    setState(() {
      questions.removeAt(index);
    });
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

  Future<void> saveSurvey() async {
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

    setState(() => isSaving = true);

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

      if (!mounted) return;

      await loadAvailableForms();

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
      if (!mounted) return;

      customDialog(
        context: context,
        title: 'خطأ',
        message: 'حدث خطأ أثناء حفظ الاستبيان، حاول مرة أخرى.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> editForm(String formId) async {
    try {
      final json = await formRepository.getFormByIdRaw(formId);

      final formName = json["name"]?.toString() ?? "";
      final currentVersion = json["currentVersion"] ?? {};
      final apiQuestions = currentVersion["questions"] as List? ?? [];
      final apiRanges = currentVersion["scoreRanges"] as List? ?? [];

      setState(() {
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

        if (questions.isEmpty) {
          questions.add(
            QuestionItem(
              id: DateTime.now().millisecondsSinceEpoch,
              key: GlobalKey<QuestionnaireBodyState>(),
            ),
          );
        }

        diagnosisKey.currentState?.setDiagnosisRangesFromApi(apiRanges);
      });

      customDialog(
        context: context,
        title: 'وضع التعديل',
        message: 'تم تحميل الاستبيان للتعديل.',
        isInfo: true,
      );
    } catch (e) {
      customDialog(
        context: context,
        title: 'خطأ',
        message: 'حدث خطأ أثناء تحميل الاستبيان للتعديل.',
        isError: true,
      );
    }
  }

  Future<void> deleteForm(String formId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('حذف الاستبيان'),
          content: const Text('هل أنت متأكد من حذف هذا الاستبيان؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await formRepository.deleteForm(formId: formId);
      await loadAvailableForms();

      if (editingFormId == formId) {
        resetEditor();
      }

      customDialog(
        context: context,
        title: 'تم الحذف',
        message: 'تم حذف الاستبيان بنجاح.',
        isSuccess: true,
      );
    } catch (e) {
      customDialog(
        context: context,
        title: 'خطأ',
        message: 'حدث خطأ أثناء حذف الاستبيان.',
        isError: true,
      );
    }
  }

  void resetEditor() {
    setState(() {
      isEditMode = false;
      editingFormId = null;
      surveyTitleController.clear();

      questions.clear();
      questions.add(
        QuestionItem(
          id: DateTime.now().millisecondsSinceEpoch,
          key: GlobalKey<QuestionnaireBodyState>(),
        ),
      );

      diagnosisKey.currentState?.resetRanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: isEditMode ? 'تعديل استبيان' : 'إضافة استبيان جديد',
        isHomeBar: false,
      ),
      body: Container(
        width: double.infinity,
        color: backgroundColor,
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: h * 0.035,
                ),
                child: Container(
                  width: w * 0.92,
                  padding: EdgeInsets.all(w * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.88),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const QuestionnairePageHeader(),
                      SizedBox(height: h * 0.035),
                      SurveyTitleCard(controller: surveyTitleController),
                      SizedBox(height: h * 0.025),

                      ...List.generate(questions.length, (index) {
                        final question = questions[index];

                        return Padding(
                          key: ValueKey(question.id),
                          padding: EdgeInsets.only(bottom: h * 0.025),
                          child: question.isDeleting
                              ? AnimatedRemove(
                                  onAnimationEnd: () =>
                                      deleteQuestionAfterAnimation(index),
                                  child: QuestionnaireBody(
                                    key: question.key,
                                    questionIndex: index + 1,
                                    canDeleteQuestion: false,
                                    onDeleteQuestion: () {},
                                    initialData: question.initialData,
                                  ),
                                )
                              : AnimatedAdd(
                                  key: ValueKey(question.id),
                                  child: QuestionnaireBody(
                                    key: question.key,
                                    questionIndex: index + 1,
                                    canDeleteQuestion: questions.length > 1,
                                    onDeleteQuestion: () =>
                                        removeQuestion(index),
                                    initialData: question.initialData,
                                  ),
                                ),
                        );
                      }),

                      CustomGlowButton(
                        title: 'إنشاء سؤال جديد',
                        onPressed: addQuestion,
                        icon: Icons.add,
                        isGradient: true,
                      ),

                      SizedBox(height: h * 0.03),

                      DiagnosisSection(key: diagnosisKey),

                      SizedBox(height: h * 0.03),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isEditMode)
                          CustomGlowButton(
                            title: 'إلغاء التعديل',
                            onPressed: resetEditor,
                            // textColor: Colors.white,
                            height: h * 0.033,
                            width: w * 0.07,
                            textSize: w * 0.0075,
                               icon: Icons.close,
                            ),
                            SizedBox(width: 12),
                          CustomGlowButton(
                            title: isSaving
                                ? "جاري الحفظ..."
                                : isEditMode
                                ? "حفظ التعديلات"
                                : "حفظ الاستبيان",
                            onPressed: () {
                              if (!isSaving) {
                                saveSurvey();
                              }
                            },
                            isGradient: true,
                            icon: Icons.save_outlined,
                          ),
                        ],
                      ),

                      SizedBox(height: h * 0.05),

                      _availableFormsWidget(h, w),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _availableFormsWidget(double h, double w) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.pink.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                  const Icon(Icons.list_alt_rounded, color: Color(0xFFE40070)),
           
              SizedBox(width: 10),
             customText(
                text: 'النماذج المتاحة',
                size: w * 0.015,
                bold: true,
                color: textColor,
              ),
            ],
          ),
          SizedBox(height: 20),
          if (isLoadingForms)
            customLoading()
          else if (availableForms.isEmpty)
            customText(
              text: 'لا توجد نماذج محفوظة حتى الآن.',
              size: w * 0.02,
              color: Colors.grey,
              bold: true,
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: availableForms.map((form) {
                final bool active = editingFormId == form["id"];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFFFEAF5)
                        : const Color(0xFFFFF7FC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: active
                          ?  Colors.pink
                          : Colors.pink.shade100,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.description_rounded,
                        color: Colors.pink,
                      ),
                      const SizedBox(height: 8),
                      customText(
                        text: form["name"].toString(),
                        size: h * 0.018,
                        bold: true,
                        color: const Color(0xFF7A004C),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CustomGlowButton(
                              title: 'تعديل',
                              onPressed: () => editForm(form["id"]),
                              icon: Icons.edit,
                              height: h * 0.035,
                              textSize: w  * 0.01,
                              textColor: Colors.white,
                              backgroundColor:  Colors.pink,
                            ),
                          ),
                            const SizedBox(width: 10),
                          Expanded(
                            child: CustomGlowButton(
                              title: 'حذف',
                              onPressed: () => deleteForm(form["id"]),
                              icon: Icons.delete_outline,
                                  textSize: w * 0.01,
                                    height: h * 0.035,
                                    textColor: Colors.pink,

                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
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
