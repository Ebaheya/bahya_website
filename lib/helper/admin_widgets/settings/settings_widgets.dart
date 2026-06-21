import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:bahya_website/route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsColors {
  static const Color pink = Color(0xFFE83E9B);
  static const Color purple = Color(0xFF9B2FE8);
  static const Color darkText = Color(0xFF211637);
  static const Color danger = Color(0xFFE93655);
}

class SettingsHeader extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onTranslate;

  const SettingsHeader({super.key, this.onLogout, this.onTranslate});

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderIcon(),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _MobileHeaderButton(
                    title: "Logout",
                    icon: Icons.logout_rounded,
                    color: SettingsColors.danger,
                    onTap:
                        onLogout ??
                        () async {
                          await authNotifier.logout();

                          if (!context.mounted) return;

                          context.go('/login');
                        },
                  ),
                  SizedBox(
                    height: responsiveHeight(context, 0.014, min: 10, max: 14),
                  ),
                  LanguageToggleButton(padding: EdgeInsets.zero),
                ],
              ),
            ],
          ),
          SizedBox(height: responsiveHeight(context, 0.02, min: 14, max: 20)),
          const _HeaderText(),
        ],
      );
    }

    return const Row(
      children: [
        Expanded(child: _HeaderText()),
        _HeaderIcon(),
      ],
    );
  }
}

class _MobileHeaderButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MobileHeaderButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MobileHeaderButton> createState() => _MobileHeaderButtonState();
}

class _MobileHeaderButtonState extends State<_MobileHeaderButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 18),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.014, min: 14, max: 18),
            vertical: responsiveHeight(context, 0.012, min: 9, max: 12),
          ),
          decoration: BoxDecoration(
            color: hover ? widget.color.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 14, max: 18),
            ),
            border: Border.all(color: widget.color.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: hover ? 0.12 : 0.07),
                blurRadius: hover ? 18 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: widget.color,
                size: responsiveSize(context, 0.014, min: 18, max: 22),
              ),
              SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 10)),
              customText(
                text: widget.title,
                size: responsiveSize(context, 0.0085, min: 12, max: 14),
                color: widget.color,
                bold: true,
                isEnglish: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        customText(
          text: "Settings",
          size: responsiveSize(context, 0.022, min: 24, max: 34),
          bold: true,
          color: SettingsColors.darkText,
          isEnglish: true,
          isCenter: false,
        ),
        SizedBox(height: responsiveHeight(context, 0.008, min: 6, max: 8)),
        customText(
          text: "Manage your account, preferences and system settings",
          size: responsiveSize(context, 0.009, min: 12, max: 15),
          color: Colors.grey.shade600,
          isEnglish: true,
          isCenter: false,
          maxLines: 2,
        ),
      ],
    );
  }
}

class _HeaderIcon extends StatefulWidget {
  const _HeaderIcon();

  @override
  State<_HeaderIcon> createState() => _HeaderIconState();
}

class _HeaderIconState extends State<_HeaderIcon> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.06, min: 58, max: 82);

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.08 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [SettingsColors.purple, SettingsColors.pink],
            ),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.018, min: 18, max: 24),
            ),
            boxShadow: [
              BoxShadow(
                color: SettingsColors.pink.withValues(
                  alpha: hover ? 0.28 : 0.16,
                ),
                blurRadius: hover ? 22 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: responsiveSize(context, 0.03, min: 34, max: 45),
          ),
        ),
      ),
    );
  }
}

class _MobileLogoutButton extends StatefulWidget {
  final VoidCallback onTap;

  const _MobileLogoutButton({required this.onTap});

  @override
  State<_MobileLogoutButton> createState() => _MobileLogoutButtonState();
}

class _MobileLogoutButtonState extends State<_MobileLogoutButton> {
  bool hover = false;

  @override
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () async {
          await authNotifier.logout();

          if (!context.mounted) return;

          context.go('/login');
        },
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.014, min: 14, max: 18),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.014, min: 14, max: 18),
            vertical: responsiveHeight(context, 0.012, min: 9, max: 12),
          ),
          decoration: BoxDecoration(
            color: hover ? const Color(0xFFFFEEF2) : Colors.white,
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 14, max: 18),
            ),
            border: Border.all(
              color: SettingsColors.danger.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: SettingsColors.danger.withValues(
                  alpha: hover ? 0.12 : 0.07,
                ),
                blurRadius: hover ? 18 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                color: SettingsColors.danger,
                size: responsiveSize(context, 0.014, min: 18, max: 22),
              ),
              SizedBox(width: responsiveSize(context, 0.008, min: 8, max: 10)),
              customText(
                text: "Logout",
                size: responsiveSize(context, 0.0085, min: 12, max: 14),
                color: SettingsColors.danger,
                bold: true,
                isEnglish: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientSettingsIcon extends StatelessWidget {
  final IconData icon;
  final bool hover;

  const GradientSettingsIcon({
    super.key,
    required this.icon,
    this.hover = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = responsiveSize(context, 0.038, min: 46, max: 56);

    return AnimatedScale(
      scale: hover ? 1.08 : 1,
      duration: const Duration(milliseconds: 220),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SettingsColors.purple, SettingsColors.pink],
          ),
          borderRadius: BorderRadius.circular(
            responsiveSize(context, 0.012, min: 14, max: 16),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: size * .54),
      ),
    );
  }
}

class SoftSettingsIcon extends StatelessWidget {
  final IconData icon;
  final bool danger;
  final double? size;

  const SoftSettingsIcon({
    super.key,
    required this.icon,
    this.danger = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? SettingsColors.danger : SettingsColors.pink;
    final iconBoxSize = size ?? responsiveSize(context, 0.03, min: 36, max: 42);

    return Container(
      width: iconBoxSize,
      height: iconBoxSize,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(
          responsiveSize(context, 0.01, min: 10, max: 12),
        ),
        border: Border.all(color: color.withValues(alpha: .12)),
      ),
      child: Icon(icon, color: color, size: iconBoxSize * .52),
    );
  }
}

class EditSettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const EditSettingsButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: responsiveHeight(context, 0.045, min: 34, max: 38),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: SettingsColors.pink,
          side: const BorderSide(color: Color(0xFFFF9BD0)),
          padding: EdgeInsets.symmetric(
            horizontal: responsiveSize(context, 0.014, min: 14, max: 22),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.01, min: 11, max: 13),
            ),
          ),
        ),
        child: customText(
          text: "Edit",
          size: responsiveSize(context, 0.008, min: 12, max: 14),
          color: SettingsColors.pink,
          bold: true,
          isEnglish: true,
        ),
      ),
    );
  }
}
