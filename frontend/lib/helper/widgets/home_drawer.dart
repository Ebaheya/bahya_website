import 'package:bahya_website/data/local/data_secure.dart';
import 'package:bahya_website/helper/massage_dialog.dart';
import 'package:bahya_website/helper/widgets/animated_icon.dart';
import 'package:bahya_website/route.dart';
import 'package:bahya_website/screens/profile_widget.dart';
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
    final h = getScreenHeight(context);
    final w = getScreenWidth(context);

    return Drawer(
      width: w * 0.25,
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
                    horizontal: w * 0.025,
                    vertical: h * 0.04,
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
                      //welcome text and user name
                      Column(
                        children: [
                          SizedBox(height: h * 0.02),
                          Center(
                            child: HoverWaveAvatar(
                              radius: h * 0.045,
                              iconColor: buttonColor,
                              onPressed: () {
                                Navigator.pop(context);
                                showProfileDialog(context);
                              },
                            ),
                          ),

                          SizedBox(height: h * 0.02),

                          customText(
                            text: "أهلاً بك،",
                            size: h * 0.035,
                            color: Colors.white,
                            bold: true,
                          ),

                          customText(
                            text: userName,
                            size: h * 0.03,
                            color: Colors.white,
                            bold: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.02,
                      vertical: h * 0.025,
                    ),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              _drawerItem(
                                context,
                                index: 1,
                                icon: Icons.assignment,
                                title: 'DT Questionnaire تعيين',
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/assign_questions',
                                  );
                                },
                              ),

                              _drawerItem(
                                context,
                                index: 2,
                                icon: Icons.assignment,
                                title: 'تعيين الاستئله',
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/assign_questions',
                                  );
                                },
                              ),

                              _drawerItem(
                                context,
                                index: 3,
                                icon: Icons.assignment,
                                title: 'تعيين المرضى',
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/assign_patients',
                                  );
                                },
                              ),

                              _drawerItem(
                                context,
                                index: 4,
                                icon: Icons.history,
                                title: 'الاستبيانات السابقة',
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/previous_surveys',
                                  );
                                },
                              ),

                              _drawerItem(
                                context,
                                index: 5,
                                icon: Icons.forum_rounded,
                                title: 'نموذج المتطوعين',
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    '/volunteer_survey',
                                  );
                                },
                              ),

                              _drawerItem(
                                context,
                                index: 6,
                                icon: Icons.forum_rounded,
                                title: 'Admin panel',
                                onTap: () {
                                  Navigator.pop(context);
                                  context.go('/admin');
                                },
                              ),

                              // const Spacer(),
                            ],
                          ),
                        ),
                        Spacer(),
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
    final h = getScreenHeight(context);

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
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
            children: [
              Icon(icon, color: buttonColor, size: h * 0.028),

              Spacer(),

              Expanded(
                child: customText(
                  text: title,
                  size: h * 0.018,
                  color: Colors.black87,
                  isCenter: false,
                  maxLines: 1,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: buttonColor,
                size: h * 0.018,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutItem(BuildContext context) {
    final h = getScreenHeight(context);

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          children: [
            Icon(Icons.logout_rounded, color: buttonColor, size: h * 0.03),
            SizedBox(width: h * 0.018),
            Expanded(
              child: customText(
                text: 'تسجيل الخروج',
                size: h * 0.02,
                color: textColor,
                bold: true,
                isCenter: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
