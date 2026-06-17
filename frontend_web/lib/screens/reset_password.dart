import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/animated_background.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/route.dart';
import 'package:flutter/material.dart';
import 'package:bahya_website/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, required this.token});

  final String token;

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (isLoading) return;

    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      customSnackBar(
        context: context,
        message: 'من فضلك أدخل كلمة المرور وتأكيدها',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      customSnackBar(context: context, message: 'كلمتا المرور غير متطابقتين');
      return;
    }

    setState(() => isLoading = true);

    try {
      await WebService().resetPassword(
        token: widget.token,
        newPassword: confirmPassword,
      );

      await authNotifier.completePasswordReset();

      if (!mounted) return;

      customSnackBar(
        context: context,
        message: 'تم إعادة تعيين كلمة المرور بنجاح',
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      customSnackBar(
        context: context,
        message: 'حدث خطأ أثناء إعادة تعيين كلمة المرور',
      );

      debugPrint("Error resetting password: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);
    final h = getScreenHeight(context);

    final isMobile = w < 650;
    final isTablet = w >= 650 && w < 1000;

    final cardWidth = isMobile
        ? w * 0.92
        : isTablet
        ? w * 0.62
        : w * 0.40;

    final maxCardWidth = isMobile ? double.infinity : 560.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4EF),
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveSize(context, 0.04, min: 16, max: 40),
                vertical: responsiveHeight(context, 0.04, min: 20, max: 42),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxCardWidth),
                child: Container(
                  width: cardWidth,
                  padding: EdgeInsets.all(
                    responsiveSize(context, 0.022, min: 18, max: 28),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.02, min: 18, max: 24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.12),
                        blurRadius: responsiveSize(
                          context,
                          0.025,
                          min: 18,
                          max: 30,
                        ),
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _ResetIcon(),
                                SizedBox(
                                  height: responsiveHeight(
                                    context,
                                    0.018,
                                    min: 12,
                                    max: 18,
                                  ),
                                ),
                                _ResetHeaderText(h: h, isMobile: true),
                              ],
                            )
                          : Row(
                              children: [
                                _ResetIcon(),
                                SizedBox(
                                  width: responsiveSize(
                                    context,
                                    0.014,
                                    min: 12,
                                    max: 16,
                                  ),
                                ),
                                Expanded(
                                  child: _ResetHeaderText(h: h, isMobile: false),
                                ),
                              ],
                            ),
        
                      SizedBox(
                        height: responsiveHeight(context, 0.04, min: 24, max: 34),
                      ),
        
                      buildTextField(
                        keyboardType: CustomTextFieldType.password,
                        controller: newPasswordController,
                        hintText: localizedText(context, '••••••••'),
                        obscureText: true,
                        labelText: localizedText(context, 'كلمة المرور الجديدة'),
                        suffixIcon: Icon(Icons.lock_outlined, color: iconColor),
                      ),
        
                      SizedBox(
                        height: responsiveHeight(context, 0.03, min: 18, max: 24),
                      ),
        
                      buildTextField(
                        controller: confirmPasswordController,
                        keyboardType: CustomTextFieldType.password,
                        hintText: localizedText(context, '••••••••'),
                        obscureText: true,
                        labelText: localizedText(context, 'تأكيد كلمة المرور'),
                        suffixIcon: Icon(Icons.lock_outline, color: iconColor),
                      ),
        
                      SizedBox(
                        height: responsiveHeight(context, 0.04, min: 24, max: 34),
                      ),
        
                      SizedBox(
                        width: double.infinity,
                        child: CustomGlowButton(
                          title: isLoading
                              ? 'جاري التأكيد...'
                              : 'تأكيد كلمة المرور',
                          backgroundColor: buttonColor,
                          textColor: Colors.white,
                          glowColor: Colors.pinkAccent,
                          onPressed: () {
                             isLoading ? null : _resetPassword();
                          },
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
    );
  }
}

class _ResetIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.01, min: 10, max: 12)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F7),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.012, min: 12, max: 14),
        ),
      ),
      child: Icon(
        Icons.lock_reset_rounded,
        color: iconColor,
        size: responsiveSize(context, 0.024, min: 26, max: 32),
      ),
    );
  }
}

class _ResetHeaderText extends StatelessWidget {
  final double h;
  final bool isMobile;

  const _ResetHeaderText({required this.h, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        customText(
          text: 'استرجاع كلمة المرور',
          size: responsiveHeight(context, 0.025, min: 22, max: 28),
          color: textColor,
          bold: true,
          isCenter: isMobile,
        ),
        SizedBox(height: responsiveHeight(context, 0.008, min: 5, max: 7)),
        customText(
          text: 'قم بإدخال كلمة المرور الجديدة',
          size: responsiveHeight(context, 0.016, min: 14, max: 17),
          color: Colors.grey,
          bold: false,
          isCenter: isMobile,
        ),
      ],
    );
  }
}
