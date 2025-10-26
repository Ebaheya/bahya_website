import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:flutter/material.dart';

enum ContactMethod { email, phone }

void showForgetPasswordDialog(BuildContext context) {
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: 460,
                  padding: const EdgeInsets.all(24.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('استرجاع كلمة المرور',
                                  style: TextStyle(
                                    color: Color(0xFF7A104F),
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(width: 8),
                              Icon(Icons.favorite_border,
                                  color: Color(0xFFE91E63), size: 28),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'من فضلك املأ البيانات التالية وسنتواصل معك قريباً',
                            style: TextStyle(color: Color(0xFFE91E63), fontSize: 15),
                          ),
                          const SizedBox(height: 24),

                          buildTextField(
                            keyboardType: CustomTextFieldType.text,
                            hintText: 'أدخل اسمك الكامل',
                            labelText: 'اسم الشخص',
                            suffixIcon: const Icon(Icons.person_outline, color: Color(0xFFE91E63)),
                          ),
                          buildTextField(
                            keyboardType: CustomTextFieldType.email,
                            hintText: 'example@email.com',
                            labelText: 'البريد الإلكتروني',
                            suffixIcon: const Icon(Icons.email_outlined, color: Color(0xFFE91E63)),
                          ),
                          buildTextField(
                            keyboardType: CustomTextFieldType.phone,
                            hintText: '05xxxxxxxx',
                            labelText: 'رقم الهاتف',
                            suffixIcon: const Icon(Icons.phone, color: Color(0xFFE91E63)),
                          ),

                          const SizedBox(height: 12),
                          arabicText(text: 'طريقة التواصل المفضلة:', size: 14, isCenter: false, bold: true),
                          const SizedBox(height: 8),

                          _contactOption(
                            title: 'البريد الإلكتروني',
                            icon: Icons.email_outlined,
                            value: ContactMethod.email,
                            groupValue: method,
                            onChanged: (v) => setState(() => method = v!),
                          ),
                          const SizedBox(height: 8),
                          _contactOption(
                            title: 'الهاتف',
                            icon: Icons.phone,
                            value: ContactMethod.phone,
                            groupValue: method,
                            onChanged: (v) => setState(() => method = v!),
                          ),

                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: CustomGlowButton(
                                  title: 'تأكيد',
                                  backgroundColor: const Color(0xFFFF7BB0),
                                  foregroundColor: Colors.white,
                                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomGlowButton(
                                  title: 'إلغاء',
                                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Image.asset('assets/icons/breastCancerIcon.png', height: 30),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF7A104F)),
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
        reverseCurve: Curves.easeInCubic, // يُفعّل أنيميشن الرجوع
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
}) {
  final selected = value == groupValue;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            size: 14,
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
