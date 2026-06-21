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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 10),
              customText(
                text: 'النماذج المتاحة',
                size: w * 0.015,
                bold: true,
                color: textColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (controller.isLoadingForms)
            customLoading()
          else if (controller.availableForms.isEmpty)
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
              children: controller.availableForms.map((form) {
                final bool active = controller.editingFormId == form["id"];

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
                      color: active ? Colors.pink : Colors.pink.shade100,
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.description_rounded, color: Colors.pink),
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
                              onPressed: () =>
                                  controller.editForm(context, form["id"]),
                              icon: Icons.edit,
                              height: h * 0.035,
                              textSize: w * 0.0085,

                              isGradient: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomGlowButton(
                              title: 'حذف',
                              onPressed: () =>
                                  controller.deleteForm(context, form["id"]),
                              icon: Icons.delete_outline,
                              textSize: w * 0.0085,
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
