import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

enum ContactMethod { email, phone }

void forgetPasswordDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();
  final h = getScreenHeight(context);
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'forget',
    barrierColor: Colors.black.withOpacity(0.30),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, __) {
      ContactMethod method = ContactMethod.email;

      return Center(
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: 460,
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, color: iconColor),
                            onPressed: () => Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(width: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customText(
                            text: 'استرجاع كلمة المرور',
                            size: h * 0.025,
                            color: textColor,
                            bold: true,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite_border,
                            color: iconColor,
                            size: 28,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      customText(
                        text:
                            'من فضلك املأ البيانات التالية وسنتواصل معك قريباً',
                        size: h * 0.018,
                        color: textColor,
                        bold: false,
                      ),
                      const SizedBox(height: 24),
                      buildTextField(
                        controller: emailController,
                        keyboardType: CustomTextFieldType.email,
                        hintText: 'example@email.com',
                        labelText: 'البريد الإلكتروني',
                        suffixIcon: Icon(
                          Icons.email_outlined,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      customText(
                        text: 'طريقة التواصل المفضلة:',
                        size: 14,
                        isCenter: false,
                        bold: true,
                      ),
                      const SizedBox(height: 8),

                      _contactOption(
                        title: 'البريد الإلكتروني',
                        icon: Icons.email_outlined,
                        value: ContactMethod.email,
                        groupValue: method,
                        onChanged: (v) => setState(() => method = v!),
                        context: context,
                      ),
                      const SizedBox(height: 8),
                      _contactOption(
                        title: 'الهاتف',
                        icon: Icons.phone,
                        value: ContactMethod.phone,
                        groupValue: method,
                        onChanged: (v) => setState(() => method = v!),
                        context: context,
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: CustomGlowButton(
                              title: 'تأكيد',
                              backgroundColor: buttonColor,
                              textColor: Colors.white,
                              onPressed: () async {
                                if (emailController.text.isEmpty) {
                                  customSnackBar(
                                    context: context,
                                    message: 'يرجى إدخال البريد الإلكتروني',
                                  );
                                  return;
                                } else {
                                  try {
                                    await WebService().forgetPassword(
                                      email: emailController.text.trim(),
                                    );

                                    if (!context.mounted) return;

                                    customSnackBar(
                                      context: context,
                                      message:
                                          'تم إرسال تعليمات استرجاع كلمة المرور إلى بريدك الإلكتروني',
                                    );
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop();
                                  } catch (error) {
                                    if (!context.mounted) return;
                                    customSnackBar(
                                      context: context,
                                      message: 'حدث خطأ: $error',
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomGlowButton(
                              title: 'إلغاء',
                              onPressed: () => Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
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
          scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

Widget _contactOption({
  required String title,
  required IconData icon,
  required ContactMethod value,
  required ContactMethod groupValue,
  required ValueChanged<ContactMethod?> onChanged,
  required BuildContext context,
}) {
  final selected = value == groupValue;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFFFE6F0) : const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: selected ? iconColor : Colors.grey.shade300),
    ),
    child: Row(
      children: [
        Icon(icon, color: selected ? iconColor : Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: customText(
            isCenter: false,
            text: title,
            size: getScreenHeight(context) * 0.015,
            color: selected ? iconColor : Colors.grey.shade700,
            bold: true,
          ),
        ),
        Radio<ContactMethod>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: iconColor,
        ),
      ],
    ),
  );
}
