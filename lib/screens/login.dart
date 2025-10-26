import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/forget_password_dialog.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/pics/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // الكارت المتمركز
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 640,
                  ), // أقصى عرض للكارت
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.90),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 30,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF7BB0),
                                    Color(0xFFE6B3FF),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          arabicText(
                            text: 'نظام فريق الدعم النفسي',
                            size: 36,
                            color: Color(0xFF7A104F),
                          ),
                          const SizedBox(height: 8),
                          arabicText(
                            text: 'مرحباً بك في منصة الدعم والرعاية',
                            size: 16,
                            color: Color(0xFFE91E63),
                            bold: false,
                          ),
                          const SizedBox(height: 24),
                          buildTextField(
                            keyboardType: CustomTextFieldType.email,
                            hintText: 'البريد الالكترونى',
                            labelText: 'البريد الالكترونى ',
                          ),
                          buildTextField(
                            keyboardType: CustomTextFieldType.password,
                            obscureText: true,
                            hintText: 'أدخل كلمة المرور',
                            labelText: 'كلمة المرور',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF7BB0),
                                shape: const StadiumBorder(),
                                elevation: 14,
                                shadowColor: const Color(0xFFFF7BB0),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  showCustomDialog(
                                    context: context,
                                    title: 'نجاح',
                                    message: 'تم تسجيل الدخول بنجاح!',
                                    onClose: () =>
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/home',
                                        ),
                                  );
                                } else {
                                  showCustomDialog(
                                    context: context,
                                    title: 'خطأ',
                                    message: 'يرجى تصحيح الأخطاء في الحقول.',
                                  );
                                }
                              },
                              child: arabicText(
                                text: "تسجيل الدخول",
                                size: 18,
                                bold: true,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              showForgetPasswordDialog(context);
                            },
                            child: arabicText(
                              text: 'نسيت كلمة المرور؟',
                              color: Color(0xFFE91E63),
                              size: 14,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Image.asset(
                              'assets/icons/breastCancerIcon.png',
                              height: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
