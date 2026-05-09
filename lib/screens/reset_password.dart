import 'dart:ui' as html;

import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, required this.token});

  final String token;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    final h = getScreenHeight(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4EF),

      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Container(
            width: w * 0.4,

            padding: const EdgeInsets.all(28),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(24),

              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.12),

                  blurRadius: 30,

                  spreadRadius: 2,

                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F7),

                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Icon(
                        Icons.lock_reset_rounded,

                        color: iconColor,

                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          customText(
                            text: 'استرجاع كلمة المرور',

                            size: h * 0.025,

                            color: textColor,

                            bold: true,
                          ),

                          const SizedBox(height: 6),

                          customText(
                            text: 'قم بإدخال كلمة المرور الجديدة',

                            size: h * 0.017,

                            color: Colors.grey,

                            bold: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                buildTextField(
                  keyboardType: CustomTextFieldType.password,
                  controller: newPasswordController,
                  hintText: '••••••••',
                  obscureText: true,
                  labelText: 'كلمة المرور الجديدة',

                  suffixIcon: Icon(Icons.lock_outlined, color: iconColor),
                ),

                const SizedBox(height: 22),
                buildTextField(
                  controller: confirmPasswordController,
                  keyboardType: CustomTextFieldType.password,
                  hintText: '••••••••',
                  obscureText: true,
                  labelText: 'تأكيد كلمة المرور',
                  suffixIcon: Icon(Icons.lock_outline, color: iconColor),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,

                  child: CustomGlowButton(
                    title: 'تأكيد كلمة المرور',

                    backgroundColor: buttonColor,

                    textColor: Colors.white,

                    glowColor: Colors.pinkAccent,

                    onPressed: () async {
                      try {
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                              customSnackBar(
                                context: context,
                                message: 'كلمتا المرور غير متطابقتين',
                              );
                        } else {
                          await WebService().resetPassword(
                            token: widget.token,
                            newPassword: confirmPasswordController.text,
                          );
                          authNotifier.completePasswordReset();
                          customSnackBar(
                            context: context,
                            message:
                                'تم إعادة تعيين كلمة المرور بنجاح',
                          );
                          context.replace('/login');
                        }
                        debugPrint("Password reset successful");
                      } catch (e) {
                        debugPrint("Error resetting password: $e");
                      }
                    },
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
