import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/widgets/questionnaire.dart';
import 'package:flutter/material.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

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

  final List<QuestionModel> questions = [
    QuestionModel(
      question: 'هل تشعرين بالقلق أغلب الوقت؟',
      options: ['نعم', 'لا', 'أحيانًا'],
    ),
    QuestionModel(
      question: 'هل تعانين من صعوبة في النوم؟',
      options: ['نعم', 'لا', 'أحيانًا'],
    ),
    QuestionModel(
      question: 'ما الأعراض التي تشعرين بها؟',
      options: ['توتر', 'حزن', 'إرهاق', 'فقدان شهية'],
      multiSelect: true,
    ),
    QuestionModel(question: 'هل لديك ألم جسدي مستمر؟', options: ['نعم', 'لا']),
    QuestionModel(
      question: 'هل تتناولين أدوية حاليًا؟',
      options: ['نعم', 'لا'],
    ),
    QuestionModel(
      question: 'اختاري الأشياء التي تؤثر على حالتك النفسية',
      options: ['العلاج', 'الأسرة', 'العمل', 'النوم', 'الألم'],
      multiSelect: true,
    ),
  ];

  late List<Set<int>> answers;

  @override
  void initState() {
    super.initState();
    answers = List.generate(questions.length, (_) => <int>{});
  }

  int get totalPages => (questions.length / questionsPerPage).ceil();

  bool get isCurrentPageCompleted {
    final start = currentPage * questionsPerPage;
    final end = (start + questionsPerPage > questions.length)
        ? questions.length
        : start + questionsPerPage;

    for (int i = start; i < end; i++) {
      if (answers[i].isEmpty) return false;
    }

    return true;
  }

  bool get isAllCompleted {
    return answers.every((answer) => answer.isNotEmpty);
  }

  void nextPage() {
    if (!isCurrentPageCompleted) return;

    if (currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      submit();
    }
  }

  void submit() {
    if (!isAllCompleted) return;

    debugPrint('Submitted Answers: $answers');
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            questionnaireHeader(
              currentPage: currentPage,
              totalPages: totalPages,
              w: w,
              h: h,
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalPages,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  final start = pageIndex * questionsPerPage;
                  final end = (start + questionsPerPage > questions.length)
                      ? questions.length
                      : start + questionsPerPage;

                  final pageQuestions = questions.sublist(start, end);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: List.generate(pageQuestions.length, (index) {
                        final realIndex = start + index;

                        return QuestionCard(
                          number: realIndex + 1,
                          question: questions[realIndex],
                          selectedAnswers: answers[realIndex],
                          pink: pink,
                          purple: purple,
                          w: w,
                          textColor: textColor,
                          onSelect: (optionIndex) {
                            setState(() {
                              if (questions[realIndex].multiSelect) {
                                if (answers[realIndex].contains(optionIndex)) {
                                  answers[realIndex].remove(optionIndex);
                                } else {
                                  answers[realIndex].add(optionIndex);
                                }
                              } else {
                                answers[realIndex]
                                  ..clear()
                                  ..add(optionIndex);
                              }
                            });
                          },
                        );
                      }),
                    ),
                  );
                },
              ),
            ),

            bottomButton(w: w),
          ],
        ),
      ),
    );
  }

  void previousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget bottomButton({required double w}) {
    final bool enabled = currentPage == totalPages - 1
        ? isAllCompleted
        : isCurrentPageCompleted;

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
                      onTap: previousPage,
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
              onTap: enabled ? nextPage : null,
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
                  child: customText(
                    text: currentPage == totalPages - 1
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
