import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Widget animatedPageHeader({
  required BuildContext context,
  required String title,
  required IconData icon,
  String? subtitle,
  bool isHome = false,
  bool showBack = false,
  bool showTotal = false,
  bool showLanguage = false,
  int? totalCount,
  String totalLabel = 'حالة',
  VoidCallback? onProfileTap,
  VoidCallback? onBackTap,
}) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      );
    },
    child: _AnimatedPageHeaderContent(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isHome: isHome,
      showBack: showBack,
      showTotal: showTotal,
      showLanguage: showLanguage,
      totalCount: totalCount,
      totalLabel: totalLabel,
      onProfileTap: onProfileTap,
      onBackTap: onBackTap,
    ),
  );
}

class _AnimatedPageHeaderContent extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isHome;
  final bool showBack;
  final bool showTotal;
  final bool showLanguage;
  final int? totalCount;
  final String totalLabel;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBackTap;

  const _AnimatedPageHeaderContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isHome,
    required this.showBack,
    required this.showTotal,
    required this.showLanguage,
    required this.totalCount,
    required this.totalLabel,
    required this.onProfileTap,
    required this.onBackTap,
  });

  @override
  State<_AnimatedPageHeaderContent> createState() =>
      _AnimatedPageHeaderContentState();
}

class _AnimatedPageHeaderContentState extends State<_AnimatedPageHeaderContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (widget.onBackTap != null) {
      widget.onBackTap!();
      return;
    }

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: responsiveHeight(context, 0.12, min: 95, max: 125),
          ),
          padding: EdgeInsets.all(
            responsiveSize(context, 0.012, min: 16, max: 24),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 18, max: 28),
            ),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.lerp(
                Alignment.centerLeft,
                Alignment.centerRight,
                value,
              )!,
              end: Alignment.lerp(
                Alignment.centerRight,
                Alignment.centerLeft,
                value,
              )!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.18 + value * 0.10),
                blurRadius: responsiveSize(
                  context,
                  0.018 + value * 0.004,
                  min: 18,
                  max: 32,
                ),
                offset: Offset(
                  0,
                  responsiveHeight(
                    context,
                    0.012 + value * 0.004,
                    min: 7,
                    max: 14,
                  ),
                ),
              ),
            ],
          ),
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 700;

          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderMain(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  icon: widget.icon,
                ),
                const SizedBox(height: 16),
                _HeaderAction(
                  isHome: widget.isHome,
                  showBack: widget.showBack,
                  showTotal: widget.showTotal,
                  showLanguage: widget.showLanguage,
                  totalCount: widget.totalCount,
                  totalLabel: widget.totalLabel,
                  onProfileTap: widget.onProfileTap,
                  onBackTap: () => _handleBack(context),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: _HeaderMain(
                  title: widget.title,
                  subtitle: widget.subtitle,
                  icon: widget.icon,
                ),
              ),
              const SizedBox(width: 18),
              _HeaderAction(
                isHome: widget.isHome,
                showBack: widget.showBack,
                showTotal: widget.showTotal,
                showLanguage: widget.showLanguage,
                totalCount: widget.totalCount,
                totalLabel: widget.totalLabel,
                onProfileTap: widget.onProfileTap,
                onBackTap: () => _handleBack(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderMain extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const _HeaderMain({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: responsiveSize(context, 0.04, min: 50, max: 64),
          height: responsiveSize(context, 0.04, min: 50, max: 64),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.01, min: 14, max: 18),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: responsiveSize(context, 0.024, min: 26, max: 36),
          ),
        ),
        SizedBox(width: responsiveSize(context, 0.014, min: 14, max: 22)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customText(
                text: title,
                size: responsiveSize(context, 0.017, min: 20, max: 30),
                color: Colors.white,
                bold: true,
                isEnglish: true,
                isCenter: false,
                maxLines: 1,
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                SizedBox(
                  height: responsiveHeight(context, 0.008, min: 6, max: 10),
                ),
                customText(
                  text: subtitle!,
                  color: Colors.white.withValues(alpha: 0.76),
                  size: responsiveSize(context, 0.01, min: 12, max: 16),
                  isEnglish: true,
                  isCenter: false,
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final bool isHome;
  final bool showBack;
  final bool showTotal;
  final bool showLanguage;
  final int? totalCount;
  final String totalLabel;
  final VoidCallback? onProfileTap;
  final VoidCallback onBackTap;

  const _HeaderAction({
    required this.isHome,
    required this.showBack,
    required this.showTotal,
    required this.showLanguage,
    required this.totalCount,
    required this.totalLabel,
    required this.onProfileTap,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (showLanguage) {
      children.add(const LanguageToggleButton(padding: EdgeInsets.zero));
    }

    if (showTotal) {
      children.add(
        _HeaderChip(
          icon: Icons.groups_rounded,
          text: '${totalCount ?? 0} $totalLabel',
          onTap: null,
        ),
      );
    }

    if (isHome) {
      children.add(
        _HeaderChip(
          icon: Icons.person_rounded,
          text: 'Profile',
          onTap: onProfileTap,
        ),
      );
    }
    if (showBack) {
      children.add(
        _HeaderChip(
          icon: Icons.arrow_forward_rounded,
          text: 'Back',
          onTap: onBackTap,
        ),
      );
    }

    if (children.isEmpty) {
      children.add(
        _HeaderChip(
          icon: Icons.arrow_back_rounded,
          text: 'Back',
          onTap: onBackTap,
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _HeaderChip({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSize(context, 0.014, min: 14, max: 20),
        vertical: responsiveHeight(context, 0.012, min: 10, max: 14),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          customText(
            text: text,
            size: responsiveSize(context, 0.01, min: 13, max: 16),
            color: Colors.white,
            bold: true,
            isEnglish: true,
            maxLines: 1,
          ),
          SizedBox(width: responsiveSize(context, 0.006, min: 6, max: 10)),
           Icon(
            icon,
            color: Colors.white,
            size: responsiveSize(context, 0.014, min: 18, max: 22),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: child,
    );
  }
}
