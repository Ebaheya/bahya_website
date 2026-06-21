import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/helper/animated_background.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/helper/widgets/forget_password_dialog.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:bahya_website/route.dart';
import 'package:bahya_website/service/login_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _CurrentUserData {
  final String? role;
  final bool isActive;

  const _CurrentUserData({required this.role, required this.isActive});
}

class _InactiveAccountException implements Exception {}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoggingIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isAllowedRole(String? role) {
    return role == 'ADMIN' || role == 'DOCTOR' || role == 'VOLUNTEER';
  }

  bool _isInactiveLoginError(Object error) {
    final text = error.toString().toLowerCase();

    return text.contains('inactive') ||
        text.contains('not active') ||
        text.contains('deactivated') ||
        text.contains('disabled') ||
        text.contains('account_not_active') ||
        text.contains('user_inactive') ||
        text.contains('user_disabled');
  }

  Future<_CurrentUserData> _getCurrentUserData() async {
    final userInfo = await WebService().getUserInfo();
    final user = userInfo['user'] is Map ? userInfo['user'] : userInfo;

    final role = user['role']?.toString();

    final isActiveRaw =
        user['isActive'] ??
        user['active'] ??
        user['is_active'] ??
        user['status'];

    bool isActive = false;

    if (isActiveRaw is bool) {
      isActive = isActiveRaw;
    } else if (isActiveRaw is String) {
      final value = isActiveRaw.toLowerCase().trim();
      isActive = value == 'true' || value == 'active';
    } else if (isActiveRaw is num) {
      isActive = isActiveRaw == 1;
    }

    return _CurrentUserData(role: role, isActive: isActive);
  }

  Future<void> _clearLoginData() async {
    await SecureStorageService().clearTokens();
    await authNotifier.forceLogout();
  }

  void _goToHomeByRole(String role) {
    authNotifier.login(role: role);

    if (role == 'ADMIN') {
      context.go('/admin');
    } else if (role == 'VOLUNTEER') {
      context.go('/volunteer_survey');
    } else {
      context.go('/home');
    }
  }

  void _showInactiveMessage() {
    customDialog(
      context: context,
      title: 'الحساب غير مفعل',
      message: 'هذا الحساب غير مفعل، برجاء التواصل مع IT.',
      isError: true,
    );
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
                                            hintText: context.l10n.email,
                                            labelText: context.l10n.email,
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
                                            hintText:
                                                context.l10n.enterPassword,
                                            labelText: context.l10n.password,
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
                                            title: isLoggingIn
                                                ? ' Signing in...'
                                                : ' Sign in',
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

    if (isLoggingIn) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      customDialog(
        context: context,
        title: 'Error',
        message: 'Please fix the field errors.',
        isError: true,
      );
      return;
    }

    setState(() => isLoggingIn = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await login(email: email, password: password);

      final currentUser = await _getCurrentUserData();
      final role = currentUser.role;

      if (!mounted) return;

      if (!_isAllowedRole(role)) {
        await _clearLoginData();

        if (!mounted) return;

        customDialog(
          context: context,
          title: 'غير مصرح',
          message: 'الدخول غير مصرح به لهذا الحساب.',
          isError: true,
        );

        return;
      }

      if (!currentUser.isActive) {
        throw _InactiveAccountException();
      }

      customDialog(
        context: context,
        title: 'Success',
        message: 'Logged in successfully!',
        isSuccess: true,
        onClose: () {
          Navigator.of(context).pop();
          _goToHomeByRole(role!);
        },
      );
    } catch (e) {
      await _clearLoginData();

      if (!mounted) return;

      if (e is _InactiveAccountException || _isInactiveLoginError(e)) {
        _showInactiveMessage();
        return;
      }

      customDialog(
        context: context,
        title: 'Error',
        message: 'Incorrect email or password',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isLoggingIn = false);
      }
    }
  }
}
