import 'package:bahya_website/helper/animated_background.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/forget_password_dialog.dart';
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
    final h = getScreenHeight(context);
    final isMobile = w < 700;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

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
      isMobile ? 0.26 : 0.15,
      min: isMobile ? 96 : 130,
      max: isMobile ? 126 : 180,
    );

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguageController.localeNotifier,
      builder: (context, locale, _) {
        final isEnglish = locale.languageCode == 'en';

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: AnimatedBackground(
            child: SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: FocusScope.of(context).unfocus,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedPadding(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.only(bottom: keyboardInset),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          vertical: responsiveHeight(
                            context,
                            isMobile ? 0.018 : 0.04,
                            min: isMobile ? 12 : 28,
                            max: isMobile ? 18 : 40,
                          ),
                          horizontal: pagePadding,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight > keyboardInset
                                ? constraints.maxHeight - keyboardInset
                                : 0,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isMobile ? w : 640,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Align(
                                    alignment: isEnglish
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: const LanguageToggleButton(
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.014,
                                      min: 10,
                                      max: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(cardPadding),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        cardRadius,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF7A004C,
                                          ).withValues(alpha: 0.08),
                                          blurRadius: 40,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          appIcon(size: logoSize),
                                          SizedBox(
                                            height: responsiveHeight(
                                              context,
                                              isMobile ? 0.014 : 0.024,
                                              min: 12,
                                              max: 22,
                                            ),
                                          ),
                                          customText(
                                            text: 'Psychological Support Team',
                                            size: responsiveHeight(
                                              context,
                                              isMobile ? 0.03 : 0.04,
                                              min: isMobile ? 24 : 34,
                                              max: isMobile ? 32 : 44,
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
                                            text:
                                                'Welcome to the support and care platform',
                                            size: responsiveHeight(
                                              context,
                                              isMobile ? 0.017 : 0.022,
                                              min: 13,
                                              max: 20,
                                            ),
                                            color: const Color(0xFFE91E63),
                                            bold: false,
                                            maxLines: 2,
                                          ),
                                          SizedBox(
                                            height: responsiveHeight(
                                              context,
                                              isMobile ? 0.026 : 0.035,
                                              min: 20,
                                              max: 34,
                                            ),
                                          ),
                                          buildTextField(
                                            controller: emailController,
                                            keyboardType:
                                                CustomTextFieldType.email,
                                            hintText: 'Email',
                                            labelText: 'Email',
                                            textDirection: isEnglish
                                                ? TextDirection.ltr
                                                : TextDirection.rtl,
                                          ),
                                          SizedBox(
                                            height: responsiveHeight(
                                              context,
                                              0.016,
                                              min: 12,
                                              max: 16,
                                            ),
                                          ),
                                          buildTextField(
                                            controller: passwordController,
                                            keyboardType:
                                                CustomTextFieldType.password,
                                            obscureText: true,
                                            hintText: 'Enter password',
                                            labelText: 'Password',
                                            textDirection: isEnglish
                                                ? TextDirection.ltr
                                                : TextDirection.rtl,
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
                                            title: 'Sign in',
                                            backgroundColor: const Color(
                                              0xFFFF7BB0,
                                            ),
                                            textColor: Colors.white,
                                            glowColor: const Color(0xFFFF7BB0),
                                            textSize: responsiveHeight(
                                              context,
                                              0.02,
                                              min: 15,
                                              max: 20,
                                            ),
                                            onPressed: _submitLogin,
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
                                              text: 'Forgot your password?',
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
                                  SizedBox(height: h * 0.02),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      customDialog(
        context: context,
        title: 'Error',
        message: 'Please fix the field errors.',
        isError: true,
      );
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await login(email: email, password: password);

      if (!mounted) return;

      customDialog(
        context: context,
        title: 'Success',
        message: 'Logged in successfully!',
        isSuccess: true,
        onClose: () {
          Navigator.of(context).pop();
          authNotifier.login();
        },
      );
    } catch (_) {
      if (!mounted) return;

      customDialog(
        context: context,
        title: 'Error',
        message: 'Incorrect email or password',
        isError: true,
      );
    }
  }
}
