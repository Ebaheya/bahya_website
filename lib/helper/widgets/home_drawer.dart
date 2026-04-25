import 'package:flutter/material.dart';
import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';

class HomeDrawer extends StatelessWidget {
  final String userName;

  const HomeDrawer({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final h = getScreenHeight(context);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(220 * value, 0),
            child: Opacity(opacity: 1 - value, child: child),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFfca5d6), Color(0xFFDBB1FF), Color(0xFFfca5d6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Header =====
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      arabicText(
                        text: "اهلا،",
                        size: h * 0.07,
                        bold: true,
                        color: Colors.white,
                      ),
                      arabicText(
                        text: userName,
                        size: h * 0.05,
                        bold: true,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white70, thickness: 3),

                // ===== Section Title =====
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: arabicText(
                    text: 'تعيين DT Questionnaire',
                    size: h * 0.018,
                    bold: true,
                    color: const Color(0xFF831843),
                  ),
                ),

                // ===== Items =====
                _animatedItem(
                  context,
                  index: 0,
                  icon: Icons.assignment,
                  title: 'تعيين الاسئله',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/assign_questions');
                  },
                ),
                _animatedItem(
                  context,
                  index: 1,
                  icon: Icons.assignment,
                  title: 'تعيين المرضى',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/assign_patients');
                  },
                ),
                _animatedItem(
                  context,
                  index: 2,
                  icon: Icons.history,
                  title: 'الاستبيانات السابقة',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/previous_surveys');
                  },
                ),
                _animatedItem(
                  context,
                  index: 3,
                  icon: Icons.forum_rounded,
                  title: 'نموذج المتطوعين',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/volunteer_survey');
                  },
                ),

                const Divider(color: Colors.white70, thickness: 3),

                const Spacer(),

                // ===== Logout (اختياري) =====
                _animatedItem(
                  context,
                  index: 4,
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: logout logic
                    // Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    final h = getScreenHeight(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: Duration(milliseconds: 400 + (index * 120)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(40 * value, 0),
          child: Opacity(opacity: 1 - value, child: child),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.white),
            title: arabicText(
              text: title,
              size: h * 0.016,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
