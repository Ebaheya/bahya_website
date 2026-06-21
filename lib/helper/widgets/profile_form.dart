import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool expandName = true;
  bool expandEmail = false;
  bool expandPassword = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
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

        border: Border.all(color: Colors.pink.withValues(alpha: 0.08)),

        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.04),
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
                    color: Colors.pink.withValues(alpha: 0.08),
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

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          buildSectionCard(
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
                  hintText: localizedText(context, 'الاسم الجديد'),
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
                  hintText: localizedText(context, 'البريد الإلكتروني الجديد'),
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
                  hintText: localizedText(context, 'كلمة المرور الحالية'),
                ),

                SizedBox(height: h * 0.02),

                buildTextField(
                  controller: newPasswordController,
                  keyboardType: CustomTextFieldType.password,
                  obscureText: true,
                  hintText: localizedText(context, 'كلمة المرور الجديدة'),
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
                        currentPassword: oldPasswordController.text.trim(),
                        newPassword: newPasswordController.text.trim(),
                      );

                      if (!context.mounted) return;

                      customDialog(
                        context: context,
                        title: "تم بنجاح",
                        message: "تم تغيير كلمة المرور بنجاح",
                      );
                    } catch (e) {
                      if (!context.mounted) return;

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
        ],
      ),
    );
  }
}
