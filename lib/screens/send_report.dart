import 'dart:ui';

import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void showReportProblemDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.28),
    builder: (context) {
      return ReportProblemDialog();
    },
  );
}

class ReportProblemDialog extends StatefulWidget {
  const ReportProblemDialog({super.key});

  @override
  State<ReportProblemDialog> createState() => _ReportProblemDialogState();
}

class _ReportProblemDialogState extends State<ReportProblemDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  void submitProblem() {
    if (!formKey.currentState!.validate()) return;

    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    debugPrint('Problem title: $title');
    debugPrint('Problem body: $body');

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: customText(
          text: 'تم إرسال المشكلة بنجاح',
          size: 14,
          color: Colors.white,
        ),
        backgroundColor: Color(0xFFE83E8C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.03, min: 18, max: 42),
        vertical: responsiveHeight(context, 0.03, min: 18, max: 36),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: responsiveSize(context, 0.008, min: 10, max: 14),
          sigmaY: responsiveSize(context, 0.008, min: 10, max: 14),
        ),
        child: Container(
          width: w < 900 ? w * 0.9 : (w * 0.38).clamp(430.0, 620.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 24, max: 30),
            ),
            border: Border.all(color: const Color(0xFFFFC6DD)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE83E8C).withOpacity(0.16),
                blurRadius: responsiveSize(context, 0.02, min: 24, max: 35),
                offset: Offset(
                  0,
                  responsiveHeight(context, 0.018, min: 10, max: 15),
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 24, max: 30),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -responsiveHeight(context, 0.08, min: 55, max: 70),
                  left: -responsiveSize(context, 0.04, min: 45, max: 60),
                  child: Container(
                    width: responsiveSize(context, 0.14, min: 170, max: 210),
                    height: responsiveSize(context, 0.14, min: 170, max: 210),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFE83E8C).withOpacity(0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  padding: EdgeInsets.all(
                    responsiveSize(context, 0.022, min: 20, max: 34),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: responsiveSize(
                                context,
                                0.045,
                                min: 54,
                                max: 70,
                              ),
                              height: responsiveSize(
                                context,
                                0.045,
                                min: 54,
                                max: 70,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: buttonColor.withOpacity(0.28),
                                    blurRadius: responsiveSize(
                                      context,
                                      0.012,
                                      min: 14,
                                      max: 18,
                                    ),
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.report_problem_rounded,
                                color: Colors.white,
                                size: responsiveSize(
                                  context,
                                  0.02,
                                  min: 28,
                                  max: 34,
                                ),
                              ),
                            ),

                            SizedBox(
                              width: responsiveSize(
                                context,
                                0.014,
                                min: 14,
                                max: 24,
                              ),
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  customText(
                                    text: 'إرسال مشكلة',
                                    size: responsiveSize(
                                      context,
                                      0.014,
                                      min: 20,
                                      max: 28,
                                    ),
                                    color: textColor,
                                    bold: true,
                                    isCenter: false,
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.006,
                                      min: 4,
                                      max: 7,
                                    ),
                                  ),
                                  customText(
                                    text: 'اكتب عنوان المشكلة والتفاصيل',
                                    size: responsiveSize(
                                      context,
                                      0.008,
                                      min: 12,
                                      max: 15,
                                    ),
                                    color: Colors.grey,
                                    bold: true,
                                    isCenter: false,
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.008,
                                      min: 5,
                                      max: 9,
                                    ),
                                  ),
                                  Container(
                                    width: responsiveSize(
                                      context,
                                      0.035,
                                      min: 45,
                                      max: 55,
                                    ),
                                    height: responsiveHeight(
                                      context,
                                      0.005,
                                      min: 3,
                                      max: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: gradientColors,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: responsiveSize(
                                  context,
                                  0.028,
                                  min: 38,
                                  max: 44,
                                ),
                                height: responsiveSize(
                                  context,
                                  0.028,
                                  min: 38,
                                  max: 44,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4FA),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFC6DD),
                                  ),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: const Color(0xFFE83E8C),
                                  size: responsiveSize(
                                    context,
                                    0.014,
                                    min: 18,
                                    max: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.035,
                            min: 22,
                            max: 34,
                          ),
                        ),

                        _ProblemFieldLabel(
                          title: localizedText(context, 'عنوان المشكلة'),
                          icon: Icons.title_rounded,
                        ),
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.01,
                            min: 7,
                            max: 10,
                          ),
                        ),
                        CustomFormTextField(
                          controller: titleController,
                          hintText: localizedText(
                            context,
                            'مثال: مشكلة في تسجيل الدخول',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: CustomTextFieldType.text,
                          textDirection: TextDirection.rtl,
                        ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.025,
                            min: 18,
                            max: 26,
                          ),
                        ),

                        _ProblemFieldLabel(
                          title: localizedText(context, 'تفاصيل المشكلة'),
                          icon: Icons.notes_rounded,
                        ),
                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.01,
                            min: 7,
                            max: 10,
                          ),
                        ),
                        CustomFormTextField(
                          controller: bodyController,
                          hintText: localizedText(
                            context,
                            'اكتب تفاصيل المشكلة هنا...',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: CustomTextFieldType.text,
                          textDirection: TextDirection.rtl,
                          maxLines: 6,
                        ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.035,
                            min: 22,
                            max: 34,
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: _ProblemDialogButton(
                                title: 'إلغاء',
                                icon: Icons.close_rounded,
                                isPrimary: false,
                                onTap: () => Navigator.pop(context),
                              ),
                            ),
                            SizedBox(
                              width: responsiveSize(
                                context,
                                0.008,
                                min: 10,
                                max: 14,
                              ),
                            ),
                            Expanded(
                              child: _ProblemDialogButton(
                                title: 'إرسال',
                                icon: Icons.send_rounded,
                                isPrimary: true,
                                onTap: submitProblem,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProblemFieldLabel extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ProblemFieldLabel({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFE83E8C),
          size: responsiveSize(context, 0.011, min: 18, max: 22),
        ),
        SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 10)),
        customText(
          text: title,
          size: responsiveSize(context, 0.008, min: 12, max: 15),
          color: textColor,
          bold: true,
          isCenter: false,
        ),
      ],
    );
  }
}

class _ProblemDialogButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ProblemDialogButton({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        responsiveSize(context, 0.008, min: 12, max: 16),
      ),
      child: Container(
        height: responsiveHeight(context, 0.055, min: 42, max: 48),
        decoration: BoxDecoration(
          gradient: isPrimary ? LinearGradient(colors: gradientColors) : null,
          color: isPrimary ? null : Colors.white,
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.008, min: 12, max: 16),
          ),
          border: Border.all(
            color: isPrimary ? Colors.transparent : const Color(0xFFFFC6DD),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.25),
                    blurRadius: responsiveSize(context, 0.01, min: 10, max: 14),
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: responsiveSize(context, 0.01, min: 16, max: 18),
              color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
            ),
            SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 10)),
            customText(
              text: title,
              size: responsiveSize(context, 0.008, min: 12, max: 15),
              color: isPrimary ? Colors.white : const Color(0xFFE83E8C),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}
