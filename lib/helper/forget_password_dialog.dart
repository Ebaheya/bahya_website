import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

enum ContactMethod { email, phone }

void forgetPasswordDialog(BuildContext context) {
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
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF7A104F),
                            ),
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
                          arabicText(
                            text: 'استرجاع كلمة المرور',
                            size: getScreenHeight(context) * 0.025,
                            color: const Color(0xFF7A104F),
                            bold: true,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.favorite_border,
                            color: Color(0xFFE91E63),
                            size: 28,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      arabicText(
                        text:
                            'من فضلك املأ البيانات التالية وسنتواصل معك قريباً',
                        size: getScreenHeight(context) * 0.018,
                        color: const Color(0xFFE91E63),
                        bold: false,
                      ),
                      const SizedBox(height: 24),

                      buildTextField(
                        keyboardType: CustomTextFieldType.text,
                        hintText: 'أدخل اسمك الكامل',
                        labelText: 'اسم الشخص',
                        suffixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                      buildTextField(
                        keyboardType: CustomTextFieldType.email,
                        hintText: 'example@email.com',
                        labelText: 'البريد الإلكتروني',
                        suffixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                      buildTextField(
                        keyboardType: CustomTextFieldType.phone,
                        hintText: '020xxxxxxxxxx',
                        labelText: 'رقم الهاتف',
                        suffixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFFE91E63),
                        ),
                      ),

                      const SizedBox(height: 12),
                      arabicText(
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
                              backgroundColor: const Color(0xFFFF7BB0),
                              textColor: Colors.white,
                              onPressed: () => Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(),
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
      border: Border.all(
        color: selected ? const Color(0xFFE91E63) : Colors.grey.shade300,
      ),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: selected ? const Color(0xFFE91E63) : Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: arabicText(
            isCenter: false,
            text: title,
            size: getScreenHeight(context) * 0.015,
            color: selected ? const Color(0xFFE91E63) : Colors.grey.shade700,
            bold: true,
          ),
        ),
        Radio<ContactMethod>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: const Color(0xFFE91E63),
        ),
      ],
    ),
  );
}
