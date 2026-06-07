import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/widgets/forget_password_dialog.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:bahya_website/route.dart';
import 'package:bahya_website/service/Login_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    final isMobile = w < 700;

    final pagePadding = responsiveSize(
      context,
      isMobile ? 0.04 : 0.025,
      min: isMobile ? 14 : 16,
      max: isMobile ? 18 : 28,
    );

    final cardPadding = responsiveSize(
      context,
      isMobile ? 0.045 : 0.03,
      min: isMobile ? 18 : 24,
      max: isMobile ? 24 : 34,
    );

    final cardRadius = responsiveSize(
      context,
      isMobile ? 0.05 : 0.022,
      min: 20,
      max: 28,
    );

    final logoSize = responsiveSize(
      context,
      isMobile ? 0.34 : 0.15,
      min: isMobile ? 115 : 130,
      max: isMobile ? 150 : 180,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pics/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(isMobile ? 0.10 : 0.04),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                  vertical: responsiveHeight(
                    context,
                    isMobile ? 0.025 : 0.045,
                    min: isMobile ? 16 : 34,
                    max: isMobile ? 24 : 44,
                  ),
                  horizontal: pagePadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? w : 640),
                  child: Container(
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: Colors.white.withOpacity(0.75)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7A004C).withOpacity(0.18),
                          blurRadius: 32,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          appIcon(size: logoSize),

                          SizedBox(
                            height: responsiveHeight(
                              context,
                              isMobile ? 0.018 : 0.024,
                              min: 14,
                              max: 22,
                            ),
                          ),

                          customText(
                            text: 'فريق الدعم النفسي',
                            size: responsiveHeight(
                              context,
                              isMobile ? 0.034 : 0.04,
                              min: isMobile ? 26 : 34,
                              max: isMobile ? 34 : 44,
                            ),
                            color: const Color(0xFF7A104F),
                            bold: true,
                            maxLines: 2,
                          ),

                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.008,
                              min: 6,
                              max: 10,
                            ),
                          ),

                          customText(
                            text: 'مرحباً بك في منصة الدعم والرعاية',
                            size: responsiveHeight(
                              context,
                              isMobile ? 0.018 : 0.022,
                              min: 14,
                              max: 20,
                            ),
                            color: const Color(0xFFE91E63),
                            bold: false,
                            maxLines: 2,
                          ),

                          SizedBox(
                            height: responsiveHeight(
                              context,
                              isMobile ? 0.03 : 0.035,
                              min: 22,
                              max: 34,
                            ),
                          ),

                          buildTextField(
                            controller: emailController,
                            keyboardType: CustomTextFieldType.email,
                            hintText: localizedText(
                              context,
                              'البريد الالكترونى',
                            ),
                            labelText: localizedText(
                              context,
                              'البريد الالكترونى',
                            ),
                            textDirection: TextDirection.rtl,
                          ),

                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.014,
                              min: 10,
                              max: 14,
                            ),
                          ),

                          buildTextField(
                            controller: passwordController,
                            keyboardType: CustomTextFieldType.password,
                            obscureText: true,
                            hintText: localizedText(
                              context,
                              'أدخل كلمة المرور',
                            ),
                            labelText: localizedText(context, 'كلمة المرور'),
                            textDirection: TextDirection.rtl,
                          ),

                          SizedBox(
                            height: responsiveHeight(
                              context,
                              isMobile ? 0.024 : 0.026,
                              min: 18,
                              max: 26,
                            ),
                          ),

                          CustomGlowButton(
                            title: "تسجيل الدخول",
                            backgroundColor: const Color(0xFFFF7BB0),
                            textColor: Colors.white,
                            glowColor: const Color(0xFFFF7BB0),
                            textSize: responsiveHeight(
                              context,
                              0.02,
                              min: 15,
                              max: 20,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();

                                try {
                                  await login(email: email, password: password);

                                  if (!context.mounted) return;

                                  customDialog(
                                    context: context,
                                    title: 'نجاح',
                                    message: 'تم تسجيل الدخول بنجاح!',
                                    onClose: () {
                                      Navigator.of(context).pop();
                                      authNotifier.login();
                                    },
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;

                                  customDialog(
                                    context: context,
                                    title: 'خطأ',
                                    message: 'البريد أو كلمة المرور غير صحيحة',
                                  );
                                }
                              } else {
                                customDialog(
                                  context: context,
                                  title: 'خطأ',
                                  message: 'يرجى تصحيح الأخطاء في الحقول.',
                                );
                              }
                            },
                          ),

                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.018,
                              min: 12,
                              max: 18,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              forgetPasswordDialog(context);
                            },
                            child: customText(
                              text: 'نسيت كلمة المرور؟',
                              color: const Color(0xFFE91E63),
                              size: responsiveHeight(
                                context,
                                0.017,
                                min: 13,
                                max: 16,
                              ),
                              bold: true,
                            ),
                          ),

                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.014,
                              min: 10,
                              max: 14,
                            ),
                          ),

                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Image.asset(
                              'assets/icons/breastCancerIcon.png',
                              height: responsiveSize(
                                context,
                                isMobile ? 0.07 : 0.035,
                                min: 28,
                                max: 36,
                              ),
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
