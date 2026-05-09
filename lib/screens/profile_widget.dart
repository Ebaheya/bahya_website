import 'dart:ui';
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

void showProfileDialog(BuildContext context) {
  showDialog(
    context: context,

    barrierColor: Colors.black.withOpacity(0.2),

    builder: (context) {
      return const ProfileDialog();
    },
  );
}

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController oldPasswordController = TextEditingController();

  final TextEditingController newPasswordController = TextEditingController();

  bool expandName = false;

  bool expandEmail = false;

  bool expandPassword = false;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    final h = getScreenHeight(context);

    return Dialog(
      backgroundColor: Colors.transparent,

      insetPadding: const EdgeInsets.all(24),

      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

          child: Container(
            width: w * 0.42,

            padding: const EdgeInsets.all(28),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),

              borderRadius: BorderRadius.circular(28),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),

                  blurRadius: 30,

                  offset: const Offset(0, 15),
                ),
              ],
            ),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                mainAxisSize: MainAxisSize.min,

                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,

                        backgroundColor: buttonColor,

                        child: const Icon(
                          Icons.person,

                          color: Colors.white,

                          size: 34,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          customText(
                            text: 'الملف الشخصي',

                            size: h * 0.028,

                            color: textColor,

                            bold: true,
                          ),

                          const SizedBox(height: 6),

                          customText(
                            text: 'إدارة بيانات الحساب',

                            size: h * 0.017,

                            color: Colors.grey,

                            bold: false,
                          ),
                        ],
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },

                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  buildExpandableSection(
                    title: 'تغيير الاسم',

                    expanded: expandName,

                    onTap: () {
                      setState(() {
                        expandName = !expandName;
                      });
                    },

                    child: Column(
                      children: [
                        buildTextField(
                          controller: nameController,

                          keyboardType: CustomTextFieldType.text,

                          hintText: 'الاسم الجديد',

                          labelText: 'الاسم الجديد',
                        ),

                        const SizedBox(height: 18),

                        CustomGlowButton(
                          title: 'حفظ الاسم',

                          backgroundColor: buttonColor,

                          textColor: Colors.white,

                          glowColor: Colors.pink,

                          onPressed: () {},
                        ),
                        SizedBox(height: h * 0.02),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  buildExpandableSection(
                    title: 'تغيير البريد الإلكتروني',

                    expanded: expandEmail,

                    onTap: () {
                      setState(() {
                        expandEmail = !expandEmail;
                      });
                    },

                    child: Column(
                      children: [
                        buildTextField(
                          controller: emailController,

                          keyboardType: CustomTextFieldType.email,

                          hintText: 'البريد الإلكتروني الجديد',

                          labelText: 'البريد الإلكتروني',
                        ),

                        const SizedBox(height: 18),

                        CustomGlowButton(
                          title: 'حفظ البريد',

                          backgroundColor: buttonColor,

                          textColor: Colors.white,

                          glowColor: Colors.pink,

                          onPressed: () {},
                        ),
                        SizedBox(height: h * 0.02),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  buildExpandableSection(
                    title: 'تغيير كلمة المرور',

                    expanded: expandPassword,

                    onTap: () {
                      setState(() {
                        expandPassword = !expandPassword;
                      });
                    },

                    child: Column(
                      children: [
                        buildTextField(
                          controller: oldPasswordController,

                          keyboardType: CustomTextFieldType.password,

                          obscureText: true,

                          hintText: 'كلمة المرور الحالية',

                          labelText: 'كلمة المرور الحالية',
                        ),

                        const SizedBox(height: 18),

                        buildTextField(
                          controller: newPasswordController,

                          keyboardType: CustomTextFieldType.password,

                          obscureText: true,

                          hintText: 'كلمة المرور الجديدة',

                          labelText: 'كلمة المرور الجديدة',
                        ),

                        const SizedBox(height: 18),

                        CustomGlowButton(
                          title: 'تغيير كلمة المرور',

                          backgroundColor: buttonColor,

                          textColor: Colors.white,

                          glowColor: Colors.pink,

                          onPressed: () async {
                            try {
                              WebService().changePassword(
                                currentPassword: oldPasswordController.text
                                    .trim(),
                                newPassword: newPasswordController.text.trim(),
                              );
                              customDialog(
                                context: context,
                                title: "تم بنحاح",
                                message: " تم تغيير كلمة المرور بنجاح",
                              );
                            } catch (e) {
                              customDialog(
                                context: context,
                                title: 'خطأ',
                                message:
                                    'فشل تغيير كلمة المرور. يرجى المحاولة مرة أخرى.',
                              );
                            }
                          },
                        ),
                        SizedBox(height: h * 0.02),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,

                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),

                        side: BorderSide(color: Colors.red.withOpacity(0.3)),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () {},

                      icon: const Icon(
                        Icons.warning_amber_rounded,

                        color: Colors.red,
                      ),

                      label: customText(
                        text: 'الإبلاغ عن مشكلة',

                        size: h * 0.018,

                        color: Colors.red,

                        bold: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildExpandableSection({
    required String title,

    required bool expanded,

    required VoidCallback onTap,

    required Widget child,
  }) {
    final h = getScreenHeight(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FA),

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.pink.withOpacity(0.08)),
      ),

      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),

            onTap: onTap,

            child: Row(
              children: [
                Expanded(
                  child: customText(
                    text: title,

                    size: h * 0.02,

                    color: textColor,

                    bold: true,
                  ),
                ),

                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,

                  duration: const Duration(milliseconds: 250),

                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,

                    color: iconColor,

                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox(),

            secondChild: Padding(
              padding: const EdgeInsets.only(top: 22),

              child: child,
            ),

            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,

            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
