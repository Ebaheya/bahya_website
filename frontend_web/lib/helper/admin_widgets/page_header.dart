import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';

Widget pageHeader({
  required BuildContext context,
  required String title,
  required IconData? icon,
  String? subtitle,
  List<Widget>? widgets,
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
      widgets: widgets,
    ),
  );
}


class _AnimatedPageHeaderContent extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? widgets;

  const _AnimatedPageHeaderContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.widgets,
  });

  @override
  State<_AnimatedPageHeaderContent> createState() =>
      _AnimatedPageHeaderContentState();
}


class _AnimatedPageHeaderContentState extends State<_AnimatedPageHeaderContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final alignmentValue = _animation.value;
        final beginAlignment = Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, alignmentValue)!;
        final endAlignment = Alignment.lerp(Alignment.centerRight, Alignment.centerLeft, alignmentValue)!;

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: responsiveHeight(context, 0.12, min: 95, max: 125),
          ),
          padding: EdgeInsets.all(
            responsiveSize(context, 0.012, min: 14, max: 20),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              responsiveSize(context, 0.014, min: 16, max: 22),
            ),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: beginAlignment,
              end: endAlignment,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.18 + (alignmentValue * 0.10)),
                blurRadius: responsiveSize(
                  context,
                  0.018 + (alignmentValue * 0.004), 
                  min: 18,
                  max: 32,
                ),
                offset: Offset(
                  0,
                  responsiveHeight(
                    context,
                    0.012 + (alignmentValue * 0.004), 
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

          return isSmall
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PageHeaderMain(
                      title: widget.title,
                      subtitle: widget.subtitle,
                      icon: widget.icon,
                      hover: true, 
                    ),
                    if (widget.widgets != null &&
                        widget.widgets!.isNotEmpty) ...[
                      SizedBox(
                        height: responsiveHeight(
                          context,
                          0.018,
                          min: 12,
                          max: 18,
                        ),
                      ),
                      Wrap(
                        spacing: responsiveSize(
                          context,
                          0.008,
                          min: 8,
                          max: 12,
                        ),
                        runSpacing: responsiveHeight(
                          context,
                          0.01,
                          min: 8,
                          max: 12,
                        ),
                        children: widget.widgets!,
                      ),
                    ],
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _PageHeaderMain(
                        title: widget.title,
                        subtitle: widget.subtitle,
                        icon: widget.icon,
                        hover: true, 
                      ),
                    ),
                    if (widget.widgets != null && widget.widgets!.isNotEmpty)
                      ...widget.widgets!,
                  ],
                );
        },
      ),
    );
  }
}

class _PageHeaderMain extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool hover;

  const _PageHeaderMain({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.hover,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          AnimatedScale(
            scale: hover ? 1.08 : 1,
            duration: const Duration(milliseconds: 450),
            child: Container(
              width: responsiveSize(context, 0.04, min: 48, max: 62),
              height: responsiveSize(context, 0.04, min: 48, max: 62),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(
                  responsiveSize(context, 0.01, min: 12, max: 16),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: responsiveSize(context, 0.024, min: 26, max: 36),
              ),
            ),
          ),
        if (icon != null)
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
              if (subtitle != null) ...[
                SizedBox(
                  height: responsiveHeight(context, 0.008, min: 6, max: 10),
                ),
                customText(
                  text: subtitle!,
                  color: Colors.white.withOpacity(0.75),
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
