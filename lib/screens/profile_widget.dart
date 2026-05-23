import 'dart:ui';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/profile_form.dart';
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
                        ProfileForm(),
                        SizedBox(height: h * 0.03),

                        InkWell(
                          onTap: () {},
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
}
