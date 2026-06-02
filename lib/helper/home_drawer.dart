import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/widgets/animated_icon.dart';
import 'package:bahya_website/route.dart';
import 'package:bahya_website/screens/profile_widget.dart';
import 'package:bahya_website/screens/send_report.dart';
import 'package:bahya_website/service/Login_service.dart';
import 'package:flutter/material.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:go_router/go_router.dart';

class HomeDrawer extends StatelessWidget {
  final String userName;

  const HomeDrawer({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final w = getScreenWidth(context);

    final drawerWidth = (w * 0.28).clamp(360.0, 430.0);

    return Drawer(
      width: drawerWidth,
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-260 * value, 0),
            child: Opacity(opacity: 1 - value, child: child),
          );
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveSize(
                      context,
                      0.018,
                      min: 22,
                      max: 32,
                    ),
                    vertical: responsiveHeight(context, 0.04, min: 32, max: 46),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [buttonColor, const Color(0xFFC04BD6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -40,
                        top: -20,
                        child: CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 40,
                        child: Icon(
                          Icons.apps_rounded,
                          color: Colors.white.withOpacity(0.12),
                          size: 90,
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.02,
                              min: 14,
                              max: 22,
                            ),
                          ),
                          Center(
                            child: HoverWaveAvatar(
                              radius: responsiveHeight(
                                context,
                                0.045,
                                min: 36,
                                max: 46,
                              ),
                              iconColor: buttonColor,
                              onPressed: () {
                                Navigator.pop(context);
                                showProfileDialog(context);
                              },
                            ),
                          ),
                          SizedBox(
                            height: responsiveHeight(
                              context,
                              0.02,
                              min: 14,
                              max: 22,
                            ),
                          ),
                          customText(
                            text: "أهلاً بك،",
                            size: responsiveSize(
                              context,
                              0.018,
                              min: 26,
                              max: 34,
                            ),
                            color: Colors.white,
                            bold: true,
                          ),
                          customText(
                            text: userName,
                            size: responsiveSize(
                              context,
                              0.014,
                              min: 20,
                              max: 26,
                            ),
                            color: Colors.white,
                            bold: true,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsiveSize(
                        context,
                        0.014,
                        min: 18,
                        max: 26,
                      ),
                      vertical: responsiveHeight(
                        context,
                        0.025,
                        min: 18,
                        max: 28,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _drawerItem(
                                  context,
                                  index: 1,
                                  icon: Icons.report_problem_rounded,
                                  title: 'الإبلاغ عن مشكلة',
                                  onTap: () {
                                    Navigator.pop(context);
                                    showReportProblemDialog(context);
                                  },
                                ),
                                _drawerItem(
                                  context,
                                  index: 5,
                                  icon: Icons.forum_rounded,
                                  title: 'نموذج المتطوعين',
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.push('/volunteer_survey');
                                  },
                                ),
                                _drawerItem(
                                  context,
                                  index: 6,
                                  icon: Icons.admin_panel_settings_rounded,
                                  title: 'Admin panel',
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.push('/admin');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.pink.withOpacity(0.18),
                          thickness: 1,
                        ),
                        _logoutItem(context),
                      ],
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

  Widget _drawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: Duration(milliseconds: 350 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-35 * value, 0),
          child: Opacity(opacity: 1 - value, child: child),
        );
      },
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            bottom: responsiveHeight(context, 0.014, min: 10, max: 14),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
            vertical: responsiveHeight(context, 0.014, min: 11, max: 15),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: buttonColor.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
  textDirection: TextDirection.rtl,
  children: [
    Icon(
      Icons.arrow_forward_ios_rounded,
      color: buttonColor,
      size: responsiveSize(context, 0.009, min: 14, max: 18),
    ),

    Expanded(
      child: Center(
        child: customText(
          text: title,
          size: responsiveSize(context, 0.009, min: 14, max: 18),
          color: Colors.black87,
          maxLines: 1,
          isCenter: true,
        ),
      ),
    ),

    Icon(
      icon,
      color: buttonColor,
      size: responsiveSize(context, 0.014, min: 20, max: 26),
    ),
  ],
),
        ),
      ),
    );
  }

  Widget _logoutItem(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          final String? refreshToken = await SecureStorageService()
              .getRefreshToken();

          await logout(refreshToken: refreshToken!);

          customDialog(
            onClose: () {
              authNotifier.logout();
              context.go('/login');
            },
            context: context,
            title: 'تم',
            message: 'تم تسجيل الخروج بنجاح.',
          );
        } catch (e) {
          customDialog(
            context: context,
            title: 'خطأ',
            message: 'حدث خطأ أثناء تسجيل الخروج. حاول مرة أخرى.',
          );
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: responsiveSize(context, 0.012, min: 14, max: 18),
          vertical: responsiveHeight(context, 0.014, min: 10, max: 14),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEF7),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: customText(
                text: 'تسجيل الخروج',
                size: responsiveSize(context, 0.01, min: 15, max: 19),
                color: textColor,
                bold: true,
                isCenter: false,
              ),
            ),
            SizedBox(width: responsiveSize(context, 0.01, min: 10, max: 14)),
            Icon(
              Icons.logout_rounded,
              color: buttonColor,
              size: responsiveSize(context, 0.015, min: 22, max: 28),
            ),
          ],
        ),
      ),
    );
  }
}
