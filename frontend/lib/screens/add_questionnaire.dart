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

  final TextEditingController surveyTitleController = TextEditingController();

  final List<QuestionItem> questions = [
    QuestionItem(
      id: DateTime.now().millisecondsSinceEpoch,
      key: GlobalKey<QuestionnaireBodyState>(),
    ),
  ];

  final GlobalKey<DiagnosisSectionState> diagnosisKey =
      GlobalKey<DiagnosisSectionState>();

  @override
  void dispose() {
    surveyTitleController.dispose();
    super.dispose();
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

      if (question.questionType == QuestionType.single) {
        formMinScore += _minScore(scores);
        formMaxScore += _maxScore(scores);
      } else {
        formMinScore += 0;
        formMaxScore += scores.fold(0, (sum, score) => sum + score);
      }
    }

    final diagnosisState = diagnosisKey.currentState;

    if (diagnosisState == null) {
      return 'حدث خطأ أثناء قراءة بيانات التشخيص.';
    }

    final ranges = diagnosisState.getDiagnosisRanges();

    if (ranges.isEmpty) {
      return 'يجب إضافة تشخيص واحد على الأقل.';
    }

    if (formMaxScore > formMinScore && ranges.length < 2) {
      return 'يجب تقسيم التشخيص إلى نطاقين على الأقل، ولا تجعل كل النتائج تذهب لتشخيص واحد.';
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

  void saveSurvey() {
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

    customDialog(
      isSuccess: true,
      context: context,
      title: 'تم الحفظ',
      message: 'تم حفظ الاستبيان بنجاح.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: 'إضافة استبيان جديد',
        isHomeBar: false,
      ),
      body: Container(
        width: double.infinity,
        color: backgroundColor,
        child: SingleChildScrollView(
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
                                ),
                              )
                            : AnimatedAdd(
                                key: ValueKey(question.id),
                                child: QuestionnaireBody(
                                  key: question.key,
                                  questionIndex: index + 1,
                                  canDeleteQuestion: questions.length > 1,
                                  onDeleteQuestion: () => removeQuestion(index),
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

                    CustomGlowButton(
                      title: "حفظ الاستبيان",
                      onPressed: saveSurvey,
                      isGradient: true,
                      icon: Icons.save_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
