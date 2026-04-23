import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/widgets/forget_password_dialog.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                          heartSign(),
                          const SizedBox(height: 16),
                          arabicText(
                            text: 'فريق الدعم النفسي',
                            size: getScreenHeight(context) * 0.035,
                            color: Color(0xFF7A104F),
                          ),
                          const SizedBox(height: 8),
                          arabicText(
                            text: 'مرحباً بك في منصة الدعم والرعاية',
                            size: getScreenHeight(context) * 0.02,
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
                          CustomGlowButton(
                            title: "تسجيل الدخول",
                            backgroundColor: Color(0xFFFF7BB0),
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                customDialog(
                                  context: context,
                                  title: 'نجاح',
                                  message: 'تم تسجيل الدخول بنجاح!',
                                  onClose: () {
                                      Navigator.of(context).pop();
                                    context.go('/home');
                                  },
                                );
                              } else {
                                customDialog(
                                  context: context,
                                  title: 'خطأ',
                                  message: 'يرجى تصحيح الأخطاء في الحقول.',
                                );
                              }
                            },
                            glowColor: Color(0xFFFF7BB0),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              forgetPasswordDialog(context);
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
