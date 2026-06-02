import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/helper/widgets/forget_password_dialog.dart';
import 'package:bahya_app/route.dart';
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

  final WebService web = WebService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      customDialog(
        context: context,
        title: 'خطأ',
        message: 'يرجى إدخال البريد الإلكتروني وكلمة المرور.',
        isError: true,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await web.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      authNotifier.login();

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/formGate');
    } catch (e) {
      if (!mounted) return;

      customDialog(
        context: context,
        title: 'خطأ',
        message: 'البريد أو كلمة المرور غير صحيحة',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);
    final height = getScreenHeight(context);
    final isMobile = width < 700;

    final horizontalPadding = responsiveSize(
      context,
      isMobile ? 0.055 : 0.03,
      min: 18,
      max: 36,
    );

    final cardRadius = responsiveSize(context, 0.065, min: 24, max: 34);

    final logoSize = responsiveSize(
      context,
      isMobile ? 0.31 : 0.16,
      min: 115,
      max: 145,
    );

    final cardPadding = responsiveSize(
      context,
      isMobile ? 0.055 : 0.035,
      min: 20,
      max: 34,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/pics/background.png',
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.04)),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: responsiveHeight(
                      context,
                      0.035,
                      min: 24,
                      max: 44,
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? width : 430,
                    ),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        cardPadding,
                        0,
                        cardPadding,
                        cardPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.85),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withOpacity(0.16),
                            blurRadius: 35,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: Offset(
                                0,
                                -responsiveHeight(
                                  context,
                                  0.055,
                                  min: 42,
                                  max: 56,
                                ),
                              ),
                              child: Container(
                                width: logoSize,
                                height: logoSize,
                                padding: EdgeInsets.all(
                                  responsiveSize(
                                    context,
                                    0.045,
                                    min: 16,
                                    max: 22,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFE91E63,
                                      ).withOpacity(0.16),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/pics/app_icon.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            Transform.translate(
                              offset: Offset(
                                0,
                                -responsiveHeight(
                                  context,
                                  0.035,
                                  min: 24,
                                  max: 34,
                                ),
                              ),
                              child: Column(
                                children: [
                                  customText(
                                    text: 'فريق الدعم النفسي',
                                    size: responsiveSize(
                                      context,
                                      isMobile ? 0.075 : 0.04,
                                      min: 28,
                                      max: 38,
                                    ),
                                    color: const Color(0xFF7A104F),
                                    bold: true,
                                    maxLines: 2,
                                  ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.008,
                                      min: 7,
                                      max: 10,
                                    ),
                                  ),

                                  customText(
                                    text: 'مرحباً بك في منصة الدعم والرعاية',
                                    size: responsiveSize(
                                      context,
                                      isMobile ? 0.038 : 0.022,
                                      min: 15,
                                      max: 18,
                                    ),
                                    color: const Color(0xFFFF5F9E),
                                    bold: false,
                                    maxLines: 2,
                                  ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.04,
                                      min: 28,
                                      max: 42,
                                    ),
                                  ),

                                  CustomFormTextField(
                                    controller: emailController,
                                    keyboardType: CustomTextFieldType.email,
                                    hintText: 'البريد الإلكتروني',
                                    labelText: 'البريد الإلكتروني',
                                    textDirection: TextDirection.rtl,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFFE7549B),
                                    ),
                                    bordered: true,
                                    borderRadius: 28,
                                    centerHint: false,
                                    isRequired: true,
                                  ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.016,
                                      min: 12,
                                      max: 16,
                                    ),
                                  ),

                                  CustomFormTextField(
                                    controller: passwordController,
                                    keyboardType: CustomTextFieldType.password,
                                    obscureText: true,
                                    hintText: 'كلمة المرور',
                                    labelText: 'كلمة المرور',
                                    textDirection: TextDirection.rtl,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    prefixIcon: const Icon(
                                      Icons.visibility_rounded,
                                      color: Color(0xFFE7549B),
                                    ),
                                    bordered: true,
                                    borderRadius: 28,
                                    centerHint: false,
                                    isRequired: true,
                                  ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.028,
                                      min: 20,
                                      max: 28,
                                    ),
                                  ),
                                  isLoading
                                      ? customLoading()
                                      : CustomGlowButton(
                                          title: 'تسجيل الدخول',
                                          backgroundColor: const Color(
                                            0xFFFF5F9E,
                                          ),
                                          textColor: Colors.white,
                                          glowColor: const Color(0xFFFF5F9E),
                                          textSize: responsiveSize(
                                            context,
                                            0.055,
                                            min: 20,
                                            max: 24,
                                          ),
                                          onPressed: _login,
                                        ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.026,
                                      min: 20,
                                      max: 26,
                                    ),
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.withOpacity(0.25),
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: customText(
                                          text: 'أو',
                                          size: responsiveSize(
                                            context,
                                            0.038,
                                            min: 14,
                                            max: 16,
                                          ),
                                          color: const Color(0xFF777777),
                                          bold: false,
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.withOpacity(0.25),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.02,
                                      min: 14,
                                      max: 20,
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () {
                                      forgetPasswordDialog(context);
                                    },
                                    child: customText(
                                      text: 'نسيت كلمة المرور؟',
                                      size: responsiveSize(
                                        context,
                                        0.041,
                                        min: 15,
                                        max: 17,
                                      ),
                                      color: const Color(0xFFFF3F86),
                                      bold: true,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
