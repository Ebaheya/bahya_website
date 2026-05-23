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
    barrierColor: Colors.black.withOpacity(0.25),
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

  bool expandName = true;

  bool expandEmail = false;

  bool expandPassword = false;

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    final h = getScreenHeight(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: w * 0.03,
        vertical: h * 0.03,
      ),

      child: Directionality(
        textDirection: TextDirection.rtl,

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

          child: Container(
            width: w * 0.42,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),

              borderRadius: BorderRadius.circular(34),

              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.12),
                  blurRadius: 35,
                  offset: const Offset(0, 15),
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),

              child: Stack(
                children: [
                  Positioned(
                    top: -80,
                    right: -60,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  SingleChildScrollView(
                    padding: EdgeInsets.all(w * 0.025),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: h * 0.085,
                              height: h * 0.085,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: buttonColor.withOpacity(0.3),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),

                            SizedBox(width: w * 0.015),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  customText(
                                    text: "الملف الشخصي",
                                    size: h * 0.03,
                                    color: textColor,
                                    bold: true,
                                  ),

                                  SizedBox(height: h * 0.005),

                                  customText(
                                    text: "إدارة بيانات الحساب",
                                    size: h * 0.017,
                                    color: Colors.grey,
                                  ),

                                  SizedBox(height: h * 0.008),

                                  Container(
                                    width: 45,
                                    height: 4,
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

                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: h * 0.035),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildSectionCard(
                            title: "تغيير الاسم",
                            icon: Icons.person_outline_rounded,
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
                                  keyboardType: CustomTextFieldType.name,
                                  hintText: 'الاسم الجديد',
                                ),

                                SizedBox(height: h * 0.025),

                                CustomGlowButton(
                                  title: 'حفظ الاسم',
                                  backgroundColor: buttonColor,
                                  textColor: Colors.white,
                                  glowColor: Colors.pink,
                                  borderRadius: 18,
                                  width: double.infinity,
                                  height: 45,
                                  icon: Icons.person_rounded,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.025),

                        buildSectionCard(
                          title: "تغيير البريد الإلكتروني",
                          icon: Icons.email_outlined,
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
                              ),

                              SizedBox(height: h * 0.025),

                              CustomGlowButton(
                                title: 'حفظ البريد',
                                backgroundColor: buttonColor,
                                textColor: Colors.white,
                                glowColor: Colors.pink,
                                borderRadius: 18,
                                width: double.infinity,
                                height: 45,
                                icon: Icons.email_rounded,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h * 0.025),

                        buildSectionCard(
                          title: "تغيير كلمة المرور",
                          icon: Icons.lock_outline_rounded,
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
                              ),

                              SizedBox(height: h * 0.02),

                              buildTextField(
                                controller: newPasswordController,
                                keyboardType: CustomTextFieldType.password,
                                obscureText: true,
                                hintText: 'كلمة المرور الجديدة',
                              ),

                              SizedBox(height: h * 0.025),

                              CustomGlowButton(
                                title: 'تغيير كلمة المرور',
                                backgroundColor: buttonColor,
                                textColor: Colors.white,
                                glowColor: Colors.pink,
                                borderRadius: 18,
                                width: double.infinity,
                                icon: Icons.lock_rounded,
                                height: 45,
                                onPressed: () async {
                                  try {
                                    await WebService().changePassword(
                                      currentPassword: oldPasswordController
                                          .text
                                          .trim(),
                                      newPassword: newPasswordController.text
                                          .trim(),
                                    );

                                    customDialog(
                                      context: context,
                                      title: "تم بنجاح",
                                      message: "تم تغيير كلمة المرور بنجاح",
                                    );
                                  } catch (e) {
                                    customDialog(
                                      context: context,
                                      title: 'خطأ',
                                      message: 'فشل تغيير كلمة المرور',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h * 0.03),

                        InkWell(
                          onTap: () {
                            // Handle the tap event for reporting an issue
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.12),
                              ),
                              color: Colors.red.withOpacity(0.03),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 5),
                                customText(
                                  text: "الإبلاغ عن مشكلة",
                                  size: h * 0.018,
                                  color: Colors.red,
                                  bold: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget buildSectionCard({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final h = getScreenHeight(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFD),

        borderRadius: BorderRadius.circular(28),

        border: Border.all(color: Colors.pink.withOpacity(0.08)),

        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),

            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.pink, size: 28),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: customText(
                    text: title,
                    size: h * 0.022,
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
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox(),

            secondChild: Padding(
              padding: const EdgeInsets.all(12),
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
