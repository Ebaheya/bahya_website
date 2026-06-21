import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/helper/animated_background.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/helper/widgets/forget_password_dialog.dart';
import 'package:bahya_app/helper/widgets/patient/patient_home_widgets.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
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

  String _cleanError(Object error) {
    if (error is ApiException) return error.message;

    final text = error.toString();

    if (text.contains('Invalid email or password')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }

    if (text.contains('VALIDATION_ERROR')) {
      return 'تأكد من إدخال البريد الإلكتروني وكلمة المرور بشكل صحيح.';
    }

    if (text.contains('SocketException') || text.contains('Connection')) {
      return 'تعذر الاتصال بالسيرفر، تأكد من الإنترنت.';
    }

    return 'حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى.';
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr('يرجى إدخال البريد الإلكتروني وكلمة المرور.'),
        isError: true,
      );
      return;
    }

    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final role = await web.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final roleUpper = role?.toUpperCase();

      authNotifier.login(role: roleUpper);

      if (!mounted) return;

      if (roleUpper == 'ADMIN') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/adminHome',
          (route) => false,
        );
        return;
      }

      if (roleUpper == 'PATIENT') {
        Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
        return;
      }

      if (roleUpper == 'DOCTOR') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/doctorHome',
          (route) => false,
        );
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/unauthorized',
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr(e.message),
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      customDialog(
        context: context,
        title: context.tr('خطأ'),
        message: context.tr(_cleanError(e)),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showLanguageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(
            responsiveSize(context, 0.045, min: 16, max: 22),
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Directionality(
            textDirection: context.appTextDirection,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                SizedBox(height: responsiveHeight(context, 0.025)),
                customText(
                  text: context.tr('تغيير اللغة'),
                  size: responsiveSize(context, 0.05, min: 18, max: 24),
                  color: const Color(0xFF7A104F),
                  bold: true,
                ),
                SizedBox(height: responsiveHeight(context, 0.025)),
                languageFloatingButton(context: context),
                SizedBox(height: responsiveHeight(context, 0.02)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = getScreenWidth(context);

    final horizontalPadding = responsiveSize(context, 0.055, min: 18, max: 24);
    final cardPadding = responsiveSize(context, 0.055, min: 20, max: 26);
    final cardRadius = responsiveSize(context, 0.065, min: 24, max: 32);
    final logoSize = responsiveSize(context, 0.31, min: 112, max: 142);

    return Directionality(
      textDirection: context.appTextDirection,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AnimatedBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: responsiveHeight(context, 0.02, min: 14, max: 22),
                  right: context.appTextDirection == TextDirection.rtl
                      ? horizontalPadding
                      : null,
                  left: context.appTextDirection == TextDirection.ltr
                      ? horizontalPadding
                      : null,
                  child: InkWell(
                    onTap: _showLanguageSheet,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: responsiveSize(context, 0.12, min: 46, max: 54),
                      height: responsiveSize(context, 0.12, min: 46, max: 54),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.pink.withOpacity(0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.14),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: Color(0xFFE7549B),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      responsiveHeight(context, 0.11, min: 86, max: 106),
                      horizontalPadding,
                      responsiveHeight(context, 0.04, min: 26, max: 38),
                    ),
                    child: Container(
                      width: width,
                      padding: EdgeInsets.fromLTRB(
                        cardPadding,
                        0,
                        cardPadding,
                        responsiveHeight(context, 0.026, min: 18, max: 24),
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
                            color: Colors.pink.withOpacity(0.14),
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
                                  max: 54,
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
                                      color: Colors.pink.withOpacity(0.16),
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
                                    text: context.tr('مرحبا بك فى رِفْق'),
                                    size: responsiveSize(
                                      context,
                                      0.075,
                                      min: 28,
                                      max: 36,
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
                                    text: context.tr(
                                      'نأمل ان تكون صحتكم النفسية بخير',
                                    ),
                                    size: responsiveSize(
                                      context,
                                      0.038,
                                      min: 15,
                                      max: 18,
                                    ),
                                    color: Colors.pink,
                                    maxLines: 2,
                                  ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.026,
                                      min: 18,
                                      max: 26,
                                    ),
                                  ),

                                  CustomFormTextField(
                                    controller: emailController,
                                    keyboardType: CustomTextFieldType.email,
                                    hintText: context.tr('البريد الإلكتروني'),
                                    labelText: context.tr('البريد الإلكتروني'),
                                    textDirection: TextDirection.rtl,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFFE7549B),
                                    ),
                                    bordered: true,
                                    borderRadius: 18,
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
                                    hintText: context.tr('كلمة المرور'),
                                    labelText: context.tr('كلمة المرور'),
                                    textDirection: TextDirection.rtl,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFFE7549B),
                                    ),
                                    bordered: true,
                                    borderRadius: 18,
                                    centerHint: false,
                                    isRequired: true,
                                  ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.02,
                                      min: 14,
                                      max: 20,
                                    ),
                                  ),

                                  isLoading
                                      ? SizedBox(
                                          height: responsiveHeight(
                                            context,
                                            0.055,
                                            min: 44,
                                            max: 52,
                                          ),
                                          child: Center(
                                            child: customLoading(
                                              size: responsiveSize(
                                                context,
                                                0.08,
                                                min: 30,
                                                max: 38,
                                              ),
                                            ),
                                          ),
                                        )
                                      : CustomGlowButton(
                                          title: context.tr('تسجيل الدخول'),
                                          backgroundColor: Colors.pink,
                                          textColor: Colors.white,
                                          glowColor: Colors.pink,
                                          textSize: responsiveSize(
                                            context,
                                            0.055,
                                            min: 20,
                                            max: 23,
                                          ),
                                          onPressed: _login,
                                        ),

                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.018,
                                      min: 12,
                                      max: 18,
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
                                          text: context.tr('أو'),
                                          size: responsiveSize(
                                            context,
                                            0.038,
                                            min: 14,
                                            max: 16,
                                          ),
                                          color: const Color(0xFF777777),
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
                                    onTap: isLoading
                                        ? null
                                        : () => forgetPasswordDialog(context),
                                    child: customText(
                                      text: context.tr('نسيت كلمة المرور؟'),
                                      size: responsiveSize(
                                        context,
                                        0.041,
                                        min: 15,
                                        max: 17,
                                      ),
                                      color: Colors.pink,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
