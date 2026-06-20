

import 'package:bahya_app/helper/base.dart';
import 'package:bahya_app/helper/constant.dart';
import 'package:bahya_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LanguageAppBarButton extends StatefulWidget {
  const LanguageAppBarButton({super.key, required this.context});

  final BuildContext context;

  @override
  State<LanguageAppBarButton> createState() => _LanguageAppBarButtonState();
}

class _LanguageAppBarButtonState extends State<LanguageAppBarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> shimmerAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.context.l10n.isArabic;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return InkWell(
          onTap: () async {
            await changeLanguageWithLoading(widget.context);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            height: responsiveHeight(widget.context, 0.052, min: 42, max: 48),
            padding: EdgeInsets.symmetric(
              horizontal: responsiveSize(
                widget.context,
                0.025,
                min: 8,
                max: 12,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.15),
                ],
                stops: [
                  (shimmerAnimation.value - 0.4).clamp(0.0, 1.0),
                  shimmerAnimation.value.clamp(0.0, 1.0),
                  (shimmerAnimation.value + 0.4).clamp(0.0, 1.0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                customText(
                  text: isArabic ? 'EN' : 'عربي',
                  size: responsiveSize(widget.context, 0.032, min: 12, max: 14),
                  color: Colors.white,
                  bold: true,
                  isEnglish: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            responsiveSize(context, 0.04, min: 14, max: 18),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.first.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: responsiveHeight(context, 0.072, min: 56, max: 68),
                height: responsiveHeight(context, 0.072, min: 56, max: 68),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withOpacity(0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: responsiveSize(context, 0.07, min: 26, max: 32),
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.035, min: 12, max: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    customText(
                      text: title,
                      size: responsiveSize(context, 0.041, min: 15, max: 18),
                      color: const Color(0xff14213D),
                      bold: true,
                      isCenter: false,
                      maxLines: 1,
                    ),
                    SizedBox(
                      height: responsiveHeight(context, 0.006, min: 4, max: 7),
                    ),
                    customText(
                      text: subtitle,
                      size: responsiveSize(context, 0.032, min: 11, max: 14),
                      color: Colors.grey[600],
                      isCenter: false,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsiveSize(context, 0.025, min: 8, max: 12)),
              Container(
                width: responsiveHeight(context, 0.044, min: 34, max: 42),
                height: responsiveHeight(context, 0.044, min: 34, max: 42),
                decoration: BoxDecoration(
                  color: colors.first.withOpacity(0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isArabic
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded,
                  color: colors.first,
                  size: responsiveSize(context, 0.038, min: 14, max: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRequestsWidget extends StatelessWidget {
  const _EmptyRequestsWidget({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('empty-requests-styled'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: EdgeInsets.symmetric(
        vertical: responsiveHeight(context, 0.045, min: 34, max: 44),
        horizontal: responsiveSize(context, 0.04, min: 14, max: 18),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff14213D).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.all_inbox_rounded,
              color: Color(0xff14213D),
              size: 42,
            ),
          ),
          const SizedBox(height: 16),
          customText(
            text: isArabic
                ? 'لا توجد طلبات واردة حالياً'
                : 'No incoming requests right now',
            size: responsiveSize(context, 0.038, min: 14, max: 16),
            color: const Color(0xff14213D),
            bold: true,
          ),
          const SizedBox(height: 6),
          customText(
            text: isArabic
                ? 'ستظهر الطلبات الجديدة هنا فور إرسالها'
                : 'New requests will appear here once submitted',
            size: responsiveSize(context, 0.032, min: 11, max: 13),
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }
}

class _AnimatedRequestCard extends StatelessWidget {
  const _AnimatedRequestCard({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 260 + (index * 45)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: Transform.scale(scale: 0.96 + (value * 0.04), child: child),
          ),
        );
      },
    );
  }
}

class _AdminSummaryCards extends StatelessWidget {
  const _AdminSummaryCards({
    super.key,
    required this.w,
    required this.h,
    required this.summary,
  });

  final double w;
  final double h;
  final Map<String, dynamic> summary;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.l10n.isArabic;

    final pending = _summaryValue(['pending', 'PENDING', 'pendingCount']);
    final approved = _summaryValue(['approved', 'APPROVED', 'approvedCount']);
    final total = _summaryValue(['total', 'totalCount', 'requests']);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _SummaryCard(
          w: w,
          h: h,
          icon: Icons.av_timer_rounded,
          count: pending,
          title: isArabic ? 'قيد المراجعة' : 'Pending',
        ),
        _SummaryCard(
          w: w,
          h: h,
          icon: Icons.favorite_rounded,
          count: total,
          title: isArabic ? 'إجمالي الطلبات' : 'Total',
        ),
        _SummaryCard(
          w: w,
          h: h,
          icon: Icons.check_circle,
          count: approved,
          title: isArabic ? 'تمت الموافقة' : 'Approved',
        ),
      ],
    );
  }

  String _summaryValue(List<String> keys) {
    for (final key in keys) {
      final value = summary[key];
      if (value != null) return value.toString();
    }
    return '0';
  }
}

class _SummaryCard extends StatefulWidget {
  const _SummaryCard({
    required this.w,
    required this.h,
    required this.icon,
    required this.count,
    required this.title,
  });

  final double w;
  final double h;
  final IconData icon;
  final String count;
  final String title;

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController pulseController;
  late final Animation<double> glowAnimation;

  int get countNumber => int.tryParse(widget.count) ?? 0;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('${widget.title}-${widget.count}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, introValue, child) {
        return Transform.scale(
          scale: 0.92 + (introValue * 0.08),
          child: Opacity(opacity: introValue.clamp(0.0, 1.0), child: child),
        );
      },
      child: AnimatedBuilder(
        animation: glowAnimation,
        builder: (context, child) {
          return Container(
            width: responsiveSize(context, 0.25, min: 92, max: 118),
            height: responsiveHeight(context, 0.05, min: 110, max: 125),
            padding: EdgeInsets.all(
              responsiveSize(context, 0.02, min: 8, max: 12),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(glowAnimation.value),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(glowAnimation.value + 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(glowAnimation.value * 0.3),
                  blurRadius: 10 * glowAnimation.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Column(
          children: [
            Icon(
              widget.icon,
              color: Colors.white,
              size: responsiveSize(context, 0.06, min: 22, max: 28),
            ),
            SizedBox(height: responsiveHeight(context, 0.006, min: 4, max: 7)),
            TweenAnimationBuilder<int>(
              key: ValueKey('${widget.title}-$countNumber'),
              tween: IntTween(begin: 0, end: countNumber),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return FittedBox(
                  child: customText(
                    text: value.toString(),
                    size: responsiveSize(context, 0.06, min: 22, max: 28),
                    color: Colors.white,
                    bold: true,
                  ),
                );
              },
            ),
            SizedBox(height: responsiveHeight(context, 0.004, min: 3, max: 5)),
            Expanded(
              child: customText(
                text: widget.title,
                size: responsiveSize(context, 0.029, min: 11, max: 14),
                maxLines: 2,
                color: Colors.white,
                bold: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
