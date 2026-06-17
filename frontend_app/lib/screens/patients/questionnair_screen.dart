import 'package:bahya_app/data/models/patient_forms_models.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/helper/widgets/patient/questionnaire.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/patient_forms_cubit.dart';
import 'package:bahya_app/logic/state/patient_forms_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController pageController = PageController();

  int currentPage = 0;
  final int questionsPerPage = 3;

  final Color pink = const Color(0xFFEC4B93);
  final Color purple = const Color(0xFF8E24E8);
  final Color textColor = const Color(0xFF8A1748);
  final Color bgColor = const Color(0xFFFFF6FC);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<PatientFormsCubit>().loadAssignmentDetails(
        widget.assignmentId,
      );
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  int totalPages(List<FormQuestionModel> questions) {
    if (questions.isEmpty) return 1;
    return (questions.length / questionsPerPage).ceil();
  }

  bool isCurrentPageCompleted(List<FormQuestionModel> questions) {
    final cubit = context.read<PatientFormsCubit>();

    final start = currentPage * questionsPerPage;
    final end = (start + questionsPerPage > questions.length)
        ? questions.length
        : start + questionsPerPage;

    for (int i = start; i < end; i++) {
      final question = questions[i];

      if (!question.required) continue;

      final answer = cubit.answers[question.id];

      if (answer == null) return false;

      if (question.type == "SCALE") {
        if (answer["value"] == null) return false;
      } else {
        final choiceIds = List<String>.from(answer["choiceIds"] ?? []);
        if (choiceIds.isEmpty) return false;
      }
    }

    return true;
  }

  bool isAllCompleted(List<FormQuestionModel> questions) {
    final cubit = context.read<PatientFormsCubit>();

    for (final question in questions) {
      if (!question.required) continue;

      final answer = cubit.answers[question.id];

      if (answer == null) return false;

      if (question.type == "SCALE") {
        if (answer["value"] == null) return false;
      } else {
        final choiceIds = List<String>.from(answer["choiceIds"] ?? []);
        if (choiceIds.isEmpty) return false;
      }
    }

    return true;
  }

  void nextPage(List<FormQuestionModel> questions) {
    if (!isCurrentPageCompleted(questions)) return;

    if (currentPage < totalPages(questions) - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      submit(questions);
    }
  }

  Future<void> submit(List<FormQuestionModel> questions) async {
    if (!isAllCompleted(questions)) return;

    await context.read<PatientFormsCubit>().submitCurrentAssignment();

    if (!mounted) return;

    final state = context.read<PatientFormsCubit>().state;

    if (state.submitResponse != null) {
      Navigator.pushReplacementNamed(context, '/patientsHome');
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  QuestionModel buildUiQuestion(FormQuestionModel question) {
    if (question.type == "SCALE") {
      final min = question.scaleMin ?? 0;
      final max = question.scaleMax ?? 10;

      return QuestionModel(
        question: question.text,
        options: List.generate(
          max - min + 1,
          (index) => (min + index).toString(),
        ),
      );
    }

    return QuestionModel(
      question: question.text,
      options: question.choices.map((e) => e.label).toList(),
      multiSelect: question.type == "MULTI_SELECT",
    );
  }

  Set<int> selectedIndexes(FormQuestionModel question) {
    final cubit = context.read<PatientFormsCubit>();
    final answer = cubit.answers[question.id];

    if (answer == null) return <int>{};

    if (question.type == "SCALE") {
      final min = question.scaleMin ?? 0;
      final value = answer["value"];

      if (value == null) return <int>{};

      return {value - min};
    }

    final choiceIds = List<String>.from(answer["choiceIds"] ?? []);

    final indexes = <int>{};

    for (int i = 0; i < question.choices.length; i++) {
      if (choiceIds.contains(question.choices[i].id)) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  void selectAnswer({
    required FormQuestionModel question,
    required int optionIndex,
  }) {
    final cubit = context.read<PatientFormsCubit>();

    if (question.type == "SCALE") {
      final min = question.scaleMin ?? 0;

      cubit.setScaleAnswer(questionId: question.id, value: min + optionIndex);
    } else if (question.type == "SINGLE_SELECT") {
      final choice = question.choices[optionIndex];

      cubit.setSingleChoiceAnswer(questionId: question.id, choiceId: choice.id);
    } else if (question.type == "MULTI_SELECT") {
      final choice = question.choices[optionIndex];

      cubit.toggleMultiChoiceAnswer(
        questionId: question.id,
        choiceId: choice.id,
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;

    return BlocConsumer<PatientFormsCubit, PatientFormsState>(
      listener: (context, state) {
        if (state.error != null) {
          customDialog(
            context: context,
            title: context.tr('خطأ'),
            message: context.tr(
              'تعذر تحميل النموذج حالياً. حاول مرة أخرى لاحقاً.',
            ),
            isError: true,
          );
        }
      },
      builder: (context, state) {
        if (state.isLoadingDetails) {
          return Scaffold(
            backgroundColor: bgColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final details = state.selectedAssignment;

        if (details == null) {
          return Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: customText(
                text: "لا يوجد نموذج متاح حالياً",
                size: w * 0.045,
                color: textColor,
              ),
            ),
          );
        }

        final questions = details.formVersion.questions;
        final pages = totalPages(questions);

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Column(
                children: [
                  questionnaireHeader(
                    currentPage: currentPage,
                    totalPages: pages,
                    w: w,
                    h: h,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pages,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index;
                        });
                      },
                      itemBuilder: (context, pageIndex) {
                        final start = pageIndex * questionsPerPage;
                        final end =
                            (start + questionsPerPage > questions.length)
                            ? questions.length
                            : start + questionsPerPage;

                        final pageQuestions = questions.sublist(start, end);

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: List.generate(pageQuestions.length, (
                              index,
                            ) {
                              final realIndex = start + index;
                              final question = questions[realIndex];

                              return QuestionCard(
                                number: realIndex + 1,
                                question: buildUiQuestion(question),
                                selectedAnswers: selectedIndexes(question),
                                pink: pink,
                                purple: purple,
                                w: w,
                                textColor: textColor,
                                onSelect: (optionIndex) {
                                  selectAnswer(
                                    question: question,
                                    optionIndex: optionIndex,
                                  );
                                },
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomButton(
                    w: w,
                    questions: questions,
                    isSubmitting: state.isSubmitting,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget bottomButton({
    required double w,
    required List<FormQuestionModel> questions,
    required bool isSubmitting,
  }) {
    final bool enabled = currentPage == totalPages(questions) - 1
        ? isAllCompleted(questions)
        : isCurrentPageCompleted(questions);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: pink.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  child: child,
                ),
              );
            },
            child: currentPage > 0
                ? Padding(
                    key: const ValueKey("back_button"),
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: isSubmitting ? null : previousPage,
                      child: Container(
                        height: 58,
                        width: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: pink.withOpacity(0.35)),
                          boxShadow: [
                            BoxShadow(
                              color: pink.withOpacity(0.15),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textColor,
                          size: w * 0.045,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey("empty_back_button")),
          ),
          Expanded(
            child: GestureDetector(
              onTap: enabled && !isSubmitting
                  ? () => nextPage(questions)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 58,
                decoration: BoxDecoration(
                  gradient: enabled
                      ? LinearGradient(colors: [purple, pink])
                      : null,
                  color: enabled ? null : Colors.grey[100],
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: enabled
                      ? [
                          BoxShadow(
                            color: pink.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : customText(
                          text: currentPage == totalPages(questions) - 1
                              ? 'إنهاء و إرسال'
                              : 'التالي',
                          size: w * 0.045,
                          color: enabled ? Colors.white : Colors.grey[600],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
