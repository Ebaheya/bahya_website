import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body.dart';
import 'package:bahya_website/helper/widgets/add_questionnaire/questionnaire_body_widgets.dart';
import 'package:bahya_website/logic/add_questionnaire_controller.dart';
import 'package:flutter/material.dart';

class AddQuestionnaire extends StatefulWidget {
  const AddQuestionnaire({super.key});

  @override
  State<AddQuestionnaire> createState() => _AddQuestionnaireState();
}

class _AddQuestionnaireState extends State<AddQuestionnaire> {
  late final AddQuestionnaireController controller;

  @override
  void initState() {
    super.initState();
    controller = AddQuestionnaireController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAvailableForms(context);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: customAppBar(
            context: context,
            title: controller.isEditMode
                ? 'تعديل استبيان'
                : 'إضافة استبيان جديد',
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
                        color: Colors.white.withValues(alpha: .88),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const QuestionnairePageHeader(),
                          SizedBox(height: h * 0.035),

                          SurveyTitleCard(
                            isEditing: true,
                            controller: controller.surveyTitleController,
                          ),

                          SizedBox(height: h * 0.025),

                          ...List.generate(controller.questions.length, (
                            index,
                          ) {
                            final question = controller.questions[index];

                            return Padding(
                              key: ValueKey(question.id),
                              padding: EdgeInsets.only(bottom: h * 0.025),
                              child: question.isDeleting
                                  ? AnimatedRemove(
                                      onAnimationEnd: () => controller
                                          .deleteQuestionAfterAnimation(index),
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
                                        canDeleteQuestion:
                                            controller.questions.length > 1,
                                        onDeleteQuestion: () => controller
                                            .removeQuestion(context, index),
                                        initialData: question.initialData,
                                      ),
                                    ),
                            );
                          }),

                          CustomGlowButton(
                            title: 'إنشاء سؤال جديد',
                            onPressed: () => controller.addQuestion(context),
                            icon: Icons.add,
                            isGradient: true,
                          ),

                          SizedBox(height: h * 0.03),

                          DiagnosisSection(key: controller.diagnosisKey),

                          SizedBox(height: h * 0.03),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (controller.isEditMode)
                                CustomGlowButton(
                                  title: 'إلغاء التعديل',
                                  onPressed: controller.resetEditor,
                                  height: h * 0.033,
                                  width: w * 0.07,
                                  textSize: w * 0.0075,
                                  icon: Icons.close,
                                ),
                              if (controller.isEditMode)
                                const SizedBox(width: 12),
                              CustomGlowButton(
                                title: controller.isSaving
                                    ? "جاري الحفظ..."
                                    : controller.isEditMode
                                    ? "حفظ التعديلات"
                                    : "حفظ الاستبيان",
                                onPressed: () {
                                  if (!controller.isSaving) {
                                    controller.saveSurvey(context);
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
      },
    );
  }

  Widget _availableFormsWidget(double h, double w) {
    final isMobile = w < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsiveSize(context, 0.018, min: 14, max: 20)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.02, min: 18, max: 24),
        ),
        border: Border.all(color: Colors.pink.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: responsiveSize(context, 0.02, min: 16, max: 22),
            offset: Offset(0, responsiveHeight(context, 0.01, min: 6, max: 10)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customText(
                text: 'النماذج المتاحة',
                size: responsiveSize(context, 0.014, min: 15, max: 24),
                bold: true,
                color: textColor,
              ),
              SizedBox(width: responsiveSize(context, 0.01, min: 8, max: 12)),
              Icon(
                Icons.list_alt_rounded,
                color: const Color(0xFFE40070),
                size: responsiveSize(context, 0.018, min: 22, max: 30),
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.024, min: 16, max: 24)),
          if (controller.isLoadingForms)
            Center(child: customLoading())
          else if (controller.availableForms.isEmpty)
            Center(
              child: customText(
                text: 'لا توجد نماذج محفوظة حتى الآن.',
                size: responsiveSize(context, 0.014, min: 15, max: 22),
                color: Colors.grey,
                bold: true,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = isMobile
                    ? constraints.maxWidth
                    : constraints.maxWidth < 850
                    ? (constraints.maxWidth - 16) / 2
                    : 320.0;

                return Wrap(
                  spacing: responsiveSize(context, 0.014, min: 12, max: 18),
                  runSpacing: responsiveHeight(
                    context,
                    0.018,
                    min: 14,
                    max: 20,
                  ),
                  children: controller.availableForms.map((form) {
                    final bool active = controller.editingFormId == form["id"];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: cardWidth,
                      padding: EdgeInsets.all(
                        responsiveSize(context, 0.016, min: 14, max: 20),
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFFFEAF5)
                            : const Color(0xFFFFF7FC),
                        borderRadius: BorderRadius.circular(
                          responsiveSize(context, 0.018, min: 16, max: 22),
                        ),
                        border: Border.all(
                          color: active ? Colors.pink : Colors.pink.shade100,
                          width: active ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: .06),
                            blurRadius: responsiveSize(
                              context,
                              0.018,
                              min: 14,
                              max: 22,
                            ),
                            offset: Offset(
                              0,
                              responsiveHeight(context, 0.008, min: 5, max: 8),
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.description_rounded,
                            color: Colors.pink,
                            size: responsiveSize(
                              context,
                              0.022,
                              min: 26,
                              max: 34,
                            ),
                          ),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.012,
                              min: 8,
                              max: 12,
                            ),
                          ),
                          customText(
                            text: form["name"].toString(),
                            size: responsiveSize(
                              context,
                              0.013,
                              min: 15,
                              max: 20,
                            ),
                            bold: true,
                            color: const Color(0xFF7A004C),
                            isCenter: false,
                            maxLines: 2,
                          ),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.018,
                              min: 14,
                              max: 18,
                            ),
                          ),
                          isMobile
                              ? Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomGlowButton(
                                        title: 'تعديل',
                                        onPressed: () => controller.editForm(
                                          context,
                                          form["id"],
                                        ),
                                        icon: Icons.edit,
                                        height: responsiveHeight(
                                          context,
                                          0.048,
                                          min: 42,
                                          max: 50,
                                        ),
                                        textSize: responsiveSize(
                                          context,
                                          0.011,
                                          min: 13,
                                          max: 16,
                                        ),
                                        isGradient: true,
                                      ),
                                    ),
                                    SizedBox(
                                      height: responsiveHeight(
                                        context,
                                        0.012,
                                        min: 10,
                                        max: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CustomGlowButton(
                                        title: 'حذف',
                                        onPressed: () => controller.deleteForm(
                                          context,
                                          form["id"],
                                        ),
                                        icon: Icons.delete_outline,
                                        height: responsiveHeight(
                                          context,
                                          0.048,
                                          min: 42,
                                          max: 50,
                                        ),
                                        textSize: responsiveSize(
                                          context,
                                          0.011,
                                          min: 13,
                                          max: 16,
                                        ),
                                        textColor: Colors.pink,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: CustomGlowButton(
                                        title: 'حذف',
                                        onPressed: () => controller.deleteForm(
                                          context,
                                          form["id"],
                                        ),
                                        icon: Icons.delete_outline,
                                        textSize: responsiveSize(
                                          context,
                                          0.0085,
                                          min: 12,
                                          max: 15,
                                        ),
                                        height: responsiveHeight(
                                          context,
                                          0.042,
                                          min: 36,
                                          max: 44,
                                        ),
                                        textColor: Colors.pink,
                                      ),
                                    ),
                                    SizedBox(
                                      width: responsiveSize(
                                        context,
                                        0.012,
                                        min: 10,
                                        max: 14,
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomGlowButton(
                                        title: 'تعديل',
                                        onPressed: () => controller.editForm(
                                          context,
                                          form["id"],
                                        ),
                                        icon: Icons.edit,
                                        height: responsiveHeight(
                                          context,
                                          0.042,
                                          min: 36,
                                          max: 44,
                                        ),
                                        textSize: responsiveSize(
                                          context,
                                          0.0085,
                                          min: 12,
                                          max: 15,
                                        ),
                                        isGradient: true,
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
