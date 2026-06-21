import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:flutter/material.dart';

void forgetPasswordDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'forget_password',
    barrierColor: Colors.black.withOpacity(0.38),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (dialogContext, _, __) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          final width = getScreenWidth(context);
          final height = getScreenHeight(context);
          final isMobile = width < 700;

          final dialogWidth = isMobile ? width * 0.90 : 480.0;

          final padding = responsiveSize(
            context,
            isMobile ? 0.055 : 0.032,
            min: 22,
            max: 34,
          );

          final iconSize = responsiveSize(
            context,
            isMobile ? 0.18 : 0.09,
            min: 72,
            max: 92,
          );

          return Center(
            child: Material(
              color: Colors.transparent,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  width: dialogWidth,
                  constraints: BoxConstraints(maxHeight: height * 0.90),
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.06, min: 26, max: 34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.18),
                        blurRadius: 35,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: Container(
                              width: responsiveSize(
                                context,
                                0.09,
                                min: 36,
                                max: 44,
                              ),
                              height: responsiveSize(
                                context,
                                0.09,
                                min: 36,
                                max: 44,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEDF6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFFB8D8),
                                ),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFFFF3F86),
                              ),
                            ),
                          ),
                        ),

                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5F9E), Color(0xFFB833E6)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF5F9E,
                                ).withOpacity(0.30),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            color: Colors.white,
                            size: responsiveSize(
                              context,
                              isMobile ? 0.09 : 0.04,
                              min: 36,
                              max: 46,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.022,
                            min: 16,
                            max: 22,
                          ),
                        ),

                        customText(
                          text: 'استرجاع كلمة المرور',
                          size: responsiveSize(
                            context,
                            isMobile ? 0.062 : 0.035,
                            min: 24,
                            max: 32,
                          ),
                          color: const Color(0xFF7A104F),
                          bold: true,
                          maxLines: 2,
                        ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.01,
                            min: 8,
                            max: 12,
                          ),
                        ),

                        customText(
                          text:
                              'اكتب بريدك الإلكتروني وسيتم إرسال تعليمات الاسترجاع',
                          size: responsiveSize(
                            context,
                            isMobile ? 0.036 : 0.02,
                            min: 14,
                            max: 17,
                          ),
                          color: const Color(0xFFFF5F9E),
                          bold: false,
                          maxLines: 2,
                        ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.035,
                            min: 26,
                            max: 36,
                          ),
                        ),

                        CustomFormTextField(
                          controller: emailController,
                          keyboardType: CustomTextFieldType.email,
                          hintText: 'البريد الإلكتروني',
                          labelText: 'البريد الإلكتروني',
                          textDirection: TextDirection.rtl,
                          autovalidateMode: AutovalidateMode.disabled,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFFE7549B),
                          ),
                          bordered: true,
                          borderRadius: 28,
                          centerHint: false,
                          isRequired: true,
                        ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.032,
                            min: 24,
                            max: 34,
                          ),
                        ),

                        isLoading
                            ? SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.07,
                                  min: 52,
                                  max: 60,
                                ),
                                child: Center(child: customLoading()),
                              )
                            : CustomGlowButton(
                                title: 'إرسال التعليمات',
                                backgroundColor: const Color(0xFFFF5F9E),
                                glowColor: const Color(0xFFFF5F9E),
                                textColor: Colors.white,
                                textSize: responsiveSize(
                                  context,
                                  0.05,
                                  min: 18,
                                  max: 22,
                                ),
                                onPressed: () async {
                                  final email = emailController.text.trim();

                                  if (email.isEmpty) {
                                    customDialog(
                                      context: context,
                                      title: 'خطأ',
                                      message: 'يرجى إدخال البريد الإلكتروني',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);

                                  try {
                                    await WebService().forgetPassword(
                                      email: email,
                                    );

                                    if (!context.mounted) return;

                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop();

                                    Future.delayed(
                                      const Duration(milliseconds: 300),
                                      () {
                                        if (!context.mounted) return;

                                        customDialog(
                                          context: context,
                                          title: 'تم الإرسال',
                                          message:
                                              'تم إرسال تعليمات استرجاع كلمة المرور إلى بريدك الإلكتروني',
                                          isSuccess: true,
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;

                                    customDialog(
                                      context: context,
                                      title: 'خطأ',
                                      message:
                                          'حدث خطأ أثناء إرسال الطلب، حاول مرة أخرى.',
                                      isError: true,
                                    );
                                  } finally {
                                    if (context.mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                              ),

                        SizedBox(
                          height: responsiveHeight(
                            context,
                            0.018,
                            min: 14,
                            max: 18,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: customText(
                            text: 'إلغاء',
                            size: responsiveSize(
                              context,
                              0.04,
                              min: 15,
                              max: 17,
                            ),
                            color: const Color(0xFFFF3F86),
                            bold: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}
