import 'dart:math' as math;
import 'package:bahya_website/data/api/web/web_service.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/custom_form_textfield.dart';
import 'package:bahya_website/helper/custom_glow_buttom.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

void showChangePasswordDialog(BuildContext context) {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.35),
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> submit() async {
            final currentPassword = currentController.text.trim();
            final newPassword = newController.text.trim();
            final confirmPassword = confirmController.text.trim();

            if (currentPassword.isEmpty ||
                newPassword.isEmpty ||
                confirmPassword.isEmpty) {
              setDialogState(() {
                errorMessage = "All fields are required";
              });
              return;
            }

            if (newPassword != confirmPassword) {
              setDialogState(() {
                errorMessage = "Passwords do not match";
              });
              return;
            }

            if (newPassword.length < 8) {
              setDialogState(() {
                errorMessage = "Password must be at least 8 characters";
              });
              return;
            }

            setDialogState(() {
              isLoading = true;
              errorMessage = null;
            });

            try {
              await WebService().changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
              );

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
            } catch (e) {
              setDialogState(() {
                isLoading = false;
                errorMessage = e.toString();
              });
            }
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(
              responsiveSize(context, 0.016, min: 16, max: 24),
            ),
            child: Container(
              width: responsiveSize(context, 0.34, min: 360, max: 440),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE040FB).withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 56,
                      bottom: 24,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        customText(
                          text: "Change Password",
                          size: responsiveSize(
                            context,
                            0.012,
                            min: 20,
                            max: 24,
                          ),
                          bold: true,
                          color: const Color(0xFFD81B60),
                          isEnglish: true,
                          isCenter: true,
                        ),
                        const SizedBox(height: 6),
                        customText(
                          text: "Update your account password securely",
                          size: responsiveSize(
                            context,
                            0.008,
                            min: 13,
                            max: 15,
                          ),
                          color: Colors.grey.shade500,
                          isEnglish: true,
                          isCenter: true,
                        ),
                        const SizedBox(height: 24),
                        CustomFormTextField(
                          hintText: "Current Password",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: CustomTextFieldType.password,
                          controller: currentController,
                          textDirection: TextDirection.ltr,
                          obscureText: true,
                          bordered: true,
                          isRequired: true,
                          prefixIcon: const Icon(
                            Icons.lock_open_rounded,
                            color: Color(0xFFE040FB),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                          hintText: "New Password",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: CustomTextFieldType.password,
                          controller: newController,
                          textDirection: TextDirection.ltr,
                          obscureText: true,
                          bordered: true,
                          isRequired: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFFE040FB),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                          hintText: "Confirm Password",
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: CustomTextFieldType.password,
                          controller: confirmController,
                          textDirection: TextDirection.ltr,
                          obscureText: true,
                          bordered: true,
                          isRequired: true,
                          prefixIcon: const Icon(
                            Icons.gpp_good_outlined,
                            color: Color(0xFFE040FB),
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFD32F2F),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: customText(
                                    text: errorMessage!,
                                    size: 13,
                                    color: const Color(0xFFD32F2F),
                                    isEnglish: true,
                                    maxLines: 2,
                                    isCenter: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: CustomGlowButton(
                                title: "Cancel",
                                onPressed: isLoading
                                    ? () {}
                                    : () => Navigator.pop(dialogContext),
                                backgroundColor: Colors.grey.shade100,
                                textColor: const Color(0xFF757575),
                                glowColor: Colors.transparent,
                                borderRadius: 14,
                                height: 48,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: isLoading
                                  ? Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFD81B60,
                                        ).withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : CustomGlowButton(
                                      title: "Save Changes",
                                      onPressed: submit,
                                      isGradient: true,
                                      glowColor: const Color(
                                        0xFFD81B60,
                                      ).withOpacity(0.3),
                                      borderRadius: 14,
                                      height: 48,
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -40,
                    left: 0,
                    right: 0,
                    child: Center(child: DialogHeaderIconAnimation()),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  });
}

class DialogHeaderIconAnimation extends StatefulWidget {
  const DialogHeaderIconAnimation({super.key});

  @override
  State<DialogHeaderIconAnimation> createState() =>
      _DialogHeaderIconAnimationState();
}

class _DialogHeaderIconAnimationState extends State<DialogHeaderIconAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 76 + (_pulseAnimation.value * 18),
              height: 76 + (_pulseAnimation.value * 18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFFE040FB,
                ).withOpacity(0.15 * (1.0 - (_pulseAnimation.value * 0.4))),
              ),
            ),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE040FB), Color(0xFFD81B60)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD81B60).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        );
      },
    );
  }
}
