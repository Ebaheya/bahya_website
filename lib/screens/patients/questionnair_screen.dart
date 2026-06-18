import 'package:bahya_app/data/models/patient_forms_models.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_app_bar.dart';
import 'package:bahya_app/helper/custom_loading.dart';
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
  final Color textColor = const Color(0xFF14213D);
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

      if (question.type == 'SCALE') {
        if (answer['value'] == null) return false;
      } else {
        final choiceIds = List<String>.from(answer['choiceIds'] ?? []);
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

      if (question.type == 'SCALE') {
        if (answer['value'] == null) return false;
      } else {
        final choiceIds = List<String>.from(answer['choiceIds'] ?? []);
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
    return QuestionModel(
      question: question.text,
      options: question.choices.map((e) => e.label).toList(),
      multiSelect: question.type == 'MULTI_SELECT',
    );
  }

  Set<int> selectedIndexes(FormQuestionModel question) {
    final cubit = context.read<PatientFormsCubit>();
    final answer = cubit.answers[question.id];

    if (answer == null) return <int>{};

    if (question.type == 'SCALE') {
      final min = question.scaleMin ?? 0;
      final value = answer['value'];

      if (value == null) return <int>{};

      return {value - min};
    }

    final choiceIds = List<String>.from(answer['choiceIds'] ?? []);
    final indexes = <int>{};

    for (int i = 0; i < question.choices.length; i++) {
      if (choiceIds.contains(question.choices[i].id)) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  int? selectedScaleValue(FormQuestionModel question) {
    final cubit = context.read<PatientFormsCubit>();
    final answer = cubit.answers[question.id];

    if (answer == null) return null;

    final value = answer['value'];
    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  void selectAnswer({
    required FormQuestionModel question,
    required int optionIndex,
  }) {
    final cubit = context.read<PatientFormsCubit>();

    if (question.type == 'SCALE') {
      final min = question.scaleMin ?? 0;

      cubit.setScaleAnswer(questionId: question.id, value: min + optionIndex);
    } else if (question.type == 'SINGLE_SELECT') {
      final choice = question.choices[optionIndex];

      cubit.setSingleChoiceAnswer(questionId: question.id, choiceId: choice.id);
    } else if (question.type == 'MULTI_SELECT') {
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
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);
    final isArabic = context.l10n.isArabic;

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
            appBar: customAppBar(
              context: context,
              title: isArabic ? 'النموذج' : 'Questionnaire',
              subTitle: isArabic ? 'جار تحميل الأسئلة' : 'Loading questions',
              isHome: false,
            ),
            body: Center(child: customLoading()),
          );
        }

        final details = state.selectedAssignment;

        if (details == null) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: customAppBar(
              context: context,
              title: isArabic ? 'النموذج' : 'Questionnaire',
              subTitle: isArabic ? 'لا يوجد نموذج متاح' : 'No form available',
              isHome: false,
            ),
            body: Center(
              child: customText(
                text: isArabic
                    ? 'لا يوجد نموذج متاح حالياً'
                    : 'No questionnaire available now',
                size: responsiveSize(context, 0.045, min: 15, max: 20),
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
            extendBodyBehindAppBar: true,
            backgroundColor: bgColor,
            appBar: customAppBar(
              context: context,
              title: isArabic ? 'النموذج' : 'Questionnaire',
              subTitle: isArabic
                  ? 'أجيبي على الأسئلة لإكمال التقييم'
                  : 'Answer the questions to complete the form',
              isHome: false,
              preferredSize: Size.fromHeight(
                responsiveHeight(context, 0.13, min: 105, max: 135),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: responsiveHeight(context, 0.015, min: 10, max: 18),
                  ),
                  progressHeader(
                    context: context,
                    currentPage: currentPage,
                    totalPages: pages,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: responsiveSize(
                              context,
                              0.04,
                              min: 14,
                              max: 20,
                            ),
                            vertical: responsiveHeight(
                              context,
                              0.018,
                              min: 12,
                              max: 18,
                            ),
                          ),
                          child: Column(
                            children: List.generate(pageQuestions.length, (
                              index,
                            ) {
                              final realIndex = start + index;
                              final question = questions[realIndex];

                              if (question.type == 'SCALE') {
                                return ScaleQuestionCard(
                                  number: realIndex + 1,
                                  question: question,
                                  selectedValue: selectedScaleValue(question),
                                  pink: pink,
                                  purple: purple,
                                  textColor: textColor,
                                  onSelect: (value) {
                                    final min = question.scaleMin ?? 0;
                                    selectAnswer(
                                      question: question,
                                      optionIndex: value - min,
                                    );
                                  },
                                );
                              }

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
                    context: context,
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

  Widget progressHeader({
    required BuildContext context,
    required int currentPage,
    required int totalPages,
  }) {
    final isArabic = context.l10n.isArabic;
    final progress = totalPages == 0 ? 0.0 : (currentPage + 1) / totalPages;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.04, min: 14, max: 20),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.035, min: 12, max: 18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.05, min: 18, max: 24),
        ),
        boxShadow: [
          BoxShadow(
            color: pink.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: responsiveHeight(context, 0.045, min: 36, max: 44),
                height: responsiveHeight(context, 0.045, min: 36, max: 44),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [purple, pink]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.025, min: 8, max: 12)),
              Expanded(
                child: customText(
                  text: isArabic
                      ? 'الصفحة ${currentPage + 1} من $totalPages'
                      : 'Page ${currentPage + 1} of $totalPages',
                  size: responsiveSize(context, 0.037, min: 13, max: 17),
                  color: textColor,
                  bold: true,
                  isCenter: false,
                ),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.012, min: 8, max: 12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: responsiveHeight(context, 0.007, min: 5, max: 8),
              value: progress,
              backgroundColor: pink.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(pink),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomButton({
    required BuildContext context,
    required List<FormQuestionModel> questions,
    required bool isSubmitting,
  }) {
    final isArabic = context.l10n.isArabic;

    final bool enabled = currentPage == totalPages(questions) - 1
        ? isAllCompleted(questions)
        : isCurrentPageCompleted(questions);

    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.04, min: 14, max: 18)),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: currentPage > 0
                ? Padding(
                    key: const ValueKey('back_button'),
                    padding: EdgeInsetsDirectional.only(
                      end: responsiveSize(context, 0.025, min: 8, max: 12),
                    ),
                    child: GestureDetector(
                      onTap: isSubmitting ? null : previousPage,
                      child: Container(
                        height: responsiveHeight(
                          context,
                          0.058,
                          min: 50,
                          max: 58,
                        ),
                        width: responsiveHeight(
                          context,
                          0.058,
                          min: 50,
                          max: 58,
                        ),
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
                          isArabic
                              ? Icons.arrow_forward_ios_rounded
                              : Icons.arrow_back_ios_new_rounded,
                          color: textColor,
                          size: responsiveSize(
                            context,
                            0.045,
                            min: 16,
                            max: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('empty_back_button')),
          ),
          Expanded(
            child: GestureDetector(
              onTap: enabled && !isSubmitting
                  ? () => nextPage(questions)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: responsiveHeight(context, 0.058, min: 50, max: 58),
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
                              ? (isArabic ? 'إنهاء و إرسال' : 'Submit')
                              : (isArabic ? 'التالي' : 'Next'),
                          size: responsiveSize(
                            context,
                            0.045,
                            min: 15,
                            max: 19,
                          ),
                          color: enabled ? Colors.white : Colors.grey[600],
                          bold: true,
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

class ScaleQuestionCard extends StatelessWidget {
  const ScaleQuestionCard({
    super.key,
    required this.number,
    required this.question,
    required this.selectedValue,
    required this.pink,
    required this.purple,
    required this.textColor,
    required this.onSelect,
  });

  final int number;
  final FormQuestionModel question;
  final int? selectedValue;
  final Color pink;
  final Color purple;
  final Color textColor;
  final void Function(int value) onSelect;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;
    final min = question.scaleMin ?? 0;
    final max = question.scaleMax ?? 10;
    final step = question.scaleStep ?? 1;

    final values = <int>[];
    for (int value = min; value <= max; value += step) {
      values.add(value);
    }

    return Container(
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.018, min: 12, max: 18),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.045, min: 15, max: 22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.055, min: 20, max: 26),
        ),
        border: Border.all(color: pink.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: pink.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: responsiveHeight(context, 0.05, min: 40, max: 50),
                height: responsiveHeight(context, 0.05, min: 40, max: 50),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [purple, pink]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: customText(
                    text: number.toString(),
                    size: responsiveSize(context, 0.04, min: 14, max: 18),
                    color: Colors.white,
                    bold: true,
                  ),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.025, min: 8, max: 12)),
              Expanded(
                child: customText(
                  text: question.text,
                  size: responsiveSize(context, 0.043, min: 15, max: 19),
                  color: textColor,
                  bold: true,
                  maxLines: 3,
                  isCenter: false,
                ),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 22)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.035, min: 12, max: 16),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6FC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: pink.withOpacity(0.10)),
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: responsiveSize(context, 0.018, min: 6, max: 10),
                  runSpacing: responsiveHeight(context, 0.01, min: 8, max: 12),
                  children: values.map((value) {
                    final selected = selectedValue == value;

                    return GestureDetector(
                      onTap: () => onSelect(value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: responsiveHeight(
                          context,
                          0.052,
                          min: 42,
                          max: 52,
                        ),
                        height: responsiveHeight(
                          context,
                          0.052,
                          min: 42,
                          max: 52,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: selected
                              ? LinearGradient(colors: [purple, pink])
                              : null,
                          color: selected ? null : Colors.white,
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : pink.withOpacity(0.22),
                            width: 1.4,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: pink.withOpacity(0.32),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: customText(
                            text: value.toString(),
                            size: responsiveSize(
                              context,
                              0.04,
                              min: 14,
                              max: 18,
                            ),
                            color: selected ? Colors.white : pink,
                            bold: true,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (selectedValue != null) ...[
                  SizedBox(
                    height: responsiveHeight(context, 0.018, min: 12, max: 18),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveSize(
                        context,
                        0.035,
                        min: 12,
                        max: 16,
                      ),
                      vertical: responsiveHeight(
                        context,
                        0.01,
                        min: 8,
                        max: 10,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: pink.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: customText(
                      text: isArabic
                          ? 'اختيارك: $selectedValue'
                          : 'Selected: $selectedValue',
                      size: responsiveSize(context, 0.033, min: 12, max: 15),
                      color: pink,
                      bold: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
