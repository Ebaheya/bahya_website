import 'dart:math' as math;

import 'package:bahya_app/data/remote/web/web_service.dart';
import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/helper/custom_glow_buttom.dart';
import 'package:bahya_app/helper/custom_loading.dart';
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
                                      0.03,
                                      min: 22,
                                      max: 32,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
