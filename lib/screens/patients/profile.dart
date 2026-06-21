import 'dart:math' as math;

import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/custom_loading.dart';
import 'package:bahya_app/helper/custom_form_textfield.dart';
import 'package:bahya_app/helper/massage_dialog.dart';
import 'package:bahya_app/helper/widgets/animated_service_card.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:bahya_app/logic/cubit/patient_profile_cubit.dart';
import 'package:bahya_app/logic/state/patient_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientProfileCubit(WebService())..loadProfile(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatefulWidget {
  const _ProfileBody();

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody>
    with TickerProviderStateMixin {
  late final AnimationController enterController;
  late final AnimationController loopController;

  late final Animation<double> fadeAnimation;
  late final Animation<double> scaleAnimation;
  late final Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 260),
    );

    loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    fadeAnimation = CurvedAnimation(
      parent: enterController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(
        parent: enterController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: enterController, curve: Curves.easeOutCubic),
        );

    enterController.forward();
  }

  @override
  void dispose() {
    enterController.dispose();
    loopController.dispose();
    super.dispose();
  }

  Future<void> closeDialog() async {
    await enterController.reverse();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _openChangePasswordDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.04, min: 14, max: 20),
        vertical: responsiveHeight(context, 0.025, min: 16, max: 24),
      ),
      child: Directionality(
        textDirection: context.appTextDirection,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: AnimatedBuilder(
                animation: loopController,
                builder: (context, child) {
                  final t = loopController.value;
                  final glow = 0.16 + (math.sin(t * math.pi * 2).abs() * 0.16);

                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      responsiveSize(context, 0.045, min: 16, max: 22),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        responsiveSize(context, 0.08, min: 30, max: 38),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(glow),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child:
                        BlocBuilder<PatientProfileCubit, PatientProfileState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.35,
                                  min: 240,
                                  max: 340,
                                ),
                                child: Center(child: customLoading()),
                              );
                            }

                            final profile = state.profile;

                            if (state.error != null || profile == null) {
                              return SizedBox(
                                height: responsiveHeight(
                                  context,
                                  0.28,
                                  min: 210,
                                  max: 280,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.red,
                                      size: responsiveSize(
                                        context,
                                        0.12,
                                        min: 42,
                                        max: 56,
                                      ),
                                    ),
                                    SizedBox(
                                      height: responsiveHeight(
                                        context,
                                        0.018,
                                        min: 12,
                                        max: 18,
                                      ),
                                    ),
                                    customText(
                                      text: isArabic
                                          ? 'حدث خطأ أثناء تحميل بيانات الحساب.'
                                          : 'Failed to load account data.',
                                      size: responsiveSize(
                                        context,
                                        0.038,
                                        min: 14,
                                        max: 18,
                                      ),
                                      color: Colors.red,
                                      bold: true,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      _closeButton(context),
                                      const Spacer(),
                                    ],
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.01,
                                      min: 6,
                                      max: 10,
                                    ),
                                  ),
                                  _animatedProfileCircle(context),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.022,
                                      min: 14,
                                      max: 22,
                                    ),
                                  ),
                                  customText(
                                    text: profile.fullName.isEmpty
                                        ? '-'
                                        : profile.fullName,
                                    size: responsiveSize(
                                      context,
                                      0.055,
                                      min: 20,
                                      max: 26,
                                    ),
                                    color: const Color(0xff14213D),
                                    bold: true,
                                    maxLines: 1,
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.008,
                                      min: 5,
                                      max: 8,
                                    ),
                                  ),
                                  customText(
                                    text: profile.email.isEmpty
                                        ? '-'
                                        : profile.email,
                                    size: responsiveSize(
                                      context,
                                      0.036,
                                      min: 13,
                                      max: 16,
                                    ),
                                    color: Colors.grey[600],
                                    isEnglish: true,
                                    maxLines: 1,
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.03,
                                      min: 20,
                                      max: 30,
                                    ),
                                  ),
                                  _infoCard(
                                    context: context,
                                    icon: Icons.person_rounded,
                                    title: isArabic ? 'الاسم' : 'Name',
                                    value: profile.fullName,
                                    color: Colors.pink,
                                  ),
                                  _infoCard(
                                    context: context,
                                    icon: Icons.email_rounded,
                                    title: isArabic
                                        ? 'البريد الإلكتروني'
                                        : 'Email',
                                    value: profile.email,
                                    color: Colors.deepPurple,
                                    isEnglish: true,
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.02,
                                      min: 14,
                                      max: 20,
                                    ),
                                  ),
                                  _ChangePasswordAction(
                                    onTap: _openChangePasswordDialog,
                                  ),
                                  SizedBox(
                                    height: responsiveHeight(
                                      context,
                                      0.014,
                                      min: 10,
                                      max: 14,
                                    ),
                                  ),
                                  CustomGlowButton(
                                    width: double.infinity,
                                    title: isArabic ? 'تسجيل الخروج' : 'Logout',
                                    onPressed: () async {
                                      if (mounted) {
                                        await closeDialog();
                                      }
                                      await context
                                          .read<PatientProfileCubit>()
                                          .logout();
                                    },
                                    textColor: Colors.white,
                                    backgroundColor: Colors.purple[400]!,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return InkWell(
      onTap: closeDialog,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: responsiveHeight(context, 0.045, min: 38, max: 46),
        height: responsiveHeight(context, 0.045, min: 38, max: 46),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          color: Colors.grey[700],
          size: responsiveSize(context, 0.055, min: 22, max: 26),
        ),
      ),
    );
  }

  Widget _animatedProfileCircle(BuildContext context) {
    return AnimatedBuilder(
      animation: loopController,
      builder: (context, child) {
        final t = loopController.value;
        final wave = math.sin(t * math.pi * 2);
        final rotate = wave * 0.035;
        final scale = 1 + wave.abs() * 0.035;

        return Transform.rotate(
          angle: rotate,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: responsiveHeight(context, 0.13, min: 95, max: 120),
              height: responsiveHeight(context, 0.13, min: 95, max: 120),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.26),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: responsiveHeight(context, 0.105, min: 76, max: 94),
                  height: responsiveHeight(context, 0.105, min: 76, max: 94),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: responsiveSize(context, 0.13, min: 48, max: 62),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isEnglish = false,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: responsiveHeight(context, 0.014, min: 10, max: 14),
      ),
      padding: EdgeInsets.all(responsiveSize(context, 0.038, min: 14, max: 18)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.045),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.05, min: 18, max: 24),
        ),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: responsiveHeight(context, 0.055, min: 42, max: 52),
            height: responsiveHeight(context, 0.055, min: 42, max: 52),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: responsiveSize(context, 0.06, min: 22, max: 28),
            ),
          ),
          SizedBox(width: responsiveSize(context, 0.03, min: 10, max: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: context.l10n.isArabic
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                customText(
                  text: title,
                  size: responsiveSize(context, 0.032, min: 12, max: 15),
                  color: Colors.grey[600],
                  bold: true,
                  isCenter: false,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.005, min: 3, max: 5),
                ),
                customText(
                  text: value.isEmpty ? '-' : value,
                  size: responsiveSize(context, 0.04, min: 15, max: 18),
                  color: const Color(0xff14213D),
                  bold: true,
                  isCenter: false,
                  isEnglish: isEnglish,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordAction extends StatefulWidget {
  const _ChangePasswordAction({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ChangePasswordAction> createState() => _ChangePasswordActionState();
}

class _ChangePasswordActionState extends State<_ChangePasswordAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = 1.0 + (controller.value * 0.025);
        final glow = 0.12 + (controller.value * 0.18);

        return Transform.scale(
          scale: scale,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                responsiveSize(context, 0.038, min: 14, max: 18),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(glow),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: responsiveHeight(context, 0.05, min: 38, max: 48),
                    height: responsiveHeight(context, 0.05, min: 38, max: 48),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                      size: responsiveSize(context, 0.06, min: 22, max: 28),
                    ),
                  ),
                  SizedBox(
                    width: responsiveSize(context, 0.03, min: 10, max: 14),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        customText(
                          text: isArabic
                              ? 'تغيير كلمة المرور'
                              : 'Change Password',
                          size: responsiveSize(
                            context,
                            0.038,
                            min: 15,
                            max: 18,
                          ),
                          color: Colors.white,
                          bold: true,
                          isCenter: false,
                        ),
                        customText(
                          text: isArabic
                              ? 'بعد التغيير ستسجلين الدخول من جديد'
                              : 'You will log in again after changing it',
                          size: responsiveSize(
                            context,
                            0.028,
                            min: 11,
                            max: 13,
                          ),
                          color: Colors.white.withOpacity(0.88),
                          isCenter: false,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isArabic
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: responsiveSize(context, 0.04, min: 16, max: 20),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog>
    with TickerProviderStateMixin {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late final AnimationController controller;
  late final Animation<double> scaleAnimation;
  late final Animation<double> fadeAnimation;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final isArabic = context.l10n.isArabic;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: isArabic
            ? 'يرجى إدخال كل البيانات.'
            : 'Please fill all fields.',
        isError: true,
      );
      return;
    }

    if (newPassword.length < 8) {
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: isArabic
            ? 'كلمة المرور الجديدة يجب ألا تقل عن 8 حروف.'
            : 'New password must be at least 8 characters.',
        isError: true,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: isArabic
            ? 'تأكيد كلمة المرور غير مطابق.'
            : 'Password confirmation does not match.',
        isError: true,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final webService = WebService();

      await webService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      await controller.reverse();
      if (!mounted) return;

      Navigator.pop(context);

      customDialog(
        context: context,
        title: isArabic ? 'تم' : 'Done',
        message: isArabic
            ? 'تم تغيير كلمة المرور بنجاح. يرجى تسجيل الدخول مرة أخرى.'
            : 'Password changed successfully. Please log in again.',
        isSuccess: true,
        onClose: () async {
          await webService.logoutAndRedirect();
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: e.message,
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      customDialog(
        context: context,
        title: isArabic ? 'خطأ' : 'Error',
        message: isArabic
            ? 'حدث خطأ أثناء تغيير كلمة المرور.'
            : 'Failed to change password.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;

    Widget dialogCardContent = Container(
      padding: EdgeInsets.all(responsiveSize(context, 0.045, min: 16, max: 22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isSaving
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFFE7549B).withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: isSaving ? null : () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: responsiveHeight(context, 0.042, min: 36, max: 44),
                    height: responsiveHeight(context, 0.042, min: 36, max: 44),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, color: Colors.grey[700]),
                  ),
                ),
                const Spacer(),
              ],
            ),
            Container(
              width: responsiveHeight(context, 0.095, min: 72, max: 90),
              height: responsiveHeight(context, 0.095, min: 72, max: 90),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradientColors),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE7549B).withOpacity(0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
            SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 20)),
            customText(
              text: isArabic ? 'تغيير كلمة المرور' : 'Change Password',
              size: responsiveSize(context, 0.05, min: 18, max: 23),
              color: const Color(0xff14213D),
              bold: true,
            ),
            SizedBox(height: responsiveHeight(context, 0.008, min: 5, max: 8)),
            customText(
              text: isArabic
                  ? 'بعد التغيير سيتم تسجيل الخروج تلقائيًا'
                  : 'After changing it, you will be logged out automatically',
              size: responsiveSize(context, 0.032, min: 12, max: 15),
              color: Colors.grey[600],
              maxLines: 2,
            ),
            SizedBox(
              height: responsiveHeight(context, 0.025, min: 18, max: 26),
            ),
            CustomFormTextField(
              controller: currentPasswordController,
              hintText: isArabic ? 'كلمة المرور الحالية' : 'Current password',
              autovalidateMode: AutovalidateMode.disabled,
              keyboardType: CustomTextFieldType.password,
              obscureText: true,
              borderRadius: 18,
              textDirection: TextDirection.ltr,
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFE7549B),
              ),
            ),
            SizedBox(
              height: responsiveHeight(context, 0.016, min: 12, max: 16),
            ),
            CustomFormTextField(
              controller: newPasswordController,
              hintText: isArabic ? 'كلمة المرور الجديدة' : 'New password',
              autovalidateMode: AutovalidateMode.disabled,
              keyboardType: CustomTextFieldType.password,
              obscureText: true,
              borderRadius: 18,
              textDirection: TextDirection.ltr,
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFE7549B),
              ),
            ),
            SizedBox(
              height: responsiveHeight(context, 0.016, min: 12, max: 16),
            ),
            CustomFormTextField(
              controller: confirmPasswordController,
              hintText: isArabic
                  ? 'تأكيد كلمة المرور الجديدة'
                  : 'Confirm new password',
              autovalidateMode: AutovalidateMode.disabled,
              keyboardType: CustomTextFieldType.password,
              obscureText: true,
              borderRadius: 18,
              textDirection: TextDirection.ltr,
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFE7549B),
              ),
            ),
            SizedBox(
              height: responsiveHeight(context, 0.028, min: 20, max: 28),
            ),
            InkWell(
              onTap: isSaving ? null : _submit,
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: double.infinity,
                height: responsiveHeight(context, 0.06, min: 48, max: 58),
                decoration: BoxDecoration(
                  color: isSaving ? Colors.transparent : Colors.purple[400],
                  borderRadius: BorderRadius.circular(18),
                  gradient: isSaving
                      ? LinearGradient(
                          colors: [
                            Colors.purple.shade300,
                            Colors.pink.shade300,
                          ],
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          customText(
                            text: isArabic
                                ? 'جاري التحديث والتأمين...'
                                : 'Securing Account...',
                            color: Colors.white,
                            bold: true,
                            size: responsiveSize(
                              context,
                              0.038,
                              min: 15,
                              max: 18,
                            ),
                          ),
                        ],
                      )
                    : customText(
                        text: isArabic ? 'حفظ كلمة المرور' : 'Save Password',
                        color: Colors.white,
                        bold: true,
                        size: responsiveSize(context, 0.038, min: 15, max: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    return Directionality(
      textDirection: context.appTextDirection,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: responsiveSize(context, 0.045, min: 16, max: 22),
            ),
            child: AnimatedServiceCard(
              borderRadius: 30.0,
              strokeWidth: 3.5,
              strokeColor: const Color(0xFFE7549B),
              duration: const Duration(seconds: 3),
              child: dialogCardContent,
            ),
          ),
        ),
      ),
    );
  }
}
