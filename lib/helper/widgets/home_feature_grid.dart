import 'package:bahya_website/helper/base.dart';
import 'package:bahya_website/helper/strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

class FeatureCard extends StatefulWidget {
  final FeatureItem item;

  const FeatureCard({super.key, required this.item});

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = getScreenWidth(context) < 650;
    final scale = _pressed ? 0.97 : (_hover && !isMobile ? 1.035 : 1.0);

    return MouseRegion(
      onEnter: (_) {
        if (!isMobile) setState(() => _hover = true);
      },
      onExit: (_) {
        if (!isMobile) setState(() => _hover = false);
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () => context.push(widget.item.route),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            padding: EdgeInsets.all(
              responsiveSize(context, 0.018, min: 16, max: 24),
            ),
            decoration: BoxDecoration(
              color: _hover ? const Color(0xFFFFF4FA) : const Color(0xFFFEFBFD),
              borderRadius: BorderRadius.circular(
                responsiveSize(context, 0.018, min: 22, max: 28),
              ),
              border: Border.all(
                color: _hover
                    ? const Color(0xFFE7549B).withValues(alpha: 0.35)
                    : const Color(0xFFE7549B).withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF831843,
                  ).withValues(alpha: _hover ? 0.16 : 0.09),
                  blurRadius: _hover ? 30 : 22,
                  offset: Offset(0, _hover ? 16 : 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.85),
                  blurRadius: 8,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: responsiveSize(context, 0.055, min: 56, max: 70),
                  height: responsiveSize(context, 0.055, min: 56, max: 70),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE7549B), Color(0xFF8A2BE2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      responsiveSize(context, 0.018, min: 20, max: 24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE7549B).withValues(alpha: 0.25),
                        blurRadius: _hover ? 22 : 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.item.icon,
                    color: Colors.white,
                    size: responsiveSize(context, 0.027, min: 28, max: 36),
                  ),
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.018, min: 14, max: 20),
                ),
                customText(
                  text: widget.item.title,
                  size: responsiveSize(context, 0.012, min: 15, max: 18),
                  bold: true,
                  color: const Color(0xFF831843),
                  maxLines: isMobile ? 1 : 2,
                  isCenter: true,
                ),
                SizedBox(
                  height: responsiveHeight(context, 0.008, min: 6, max: 10),
                ),
                customText(
                  text: widget.item.subtitle,
                  size: responsiveSize(context, 0.009, min: 12, max: 14),
                  color: const Color(0xFFE7549B),
                  maxLines: 2,
                  isCenter: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeFeaturesGrid extends StatelessWidget {
  const HomeFeaturesGrid({
    super.key,
    this.spacing = 24,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
  });

  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final items = homeFeatures(context);
    final width = getScreenWidth(context);

    final isMobile = width < 650;
    final isTablet = width >= 650 && width < 1050;

    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);
    final aspectRatio = isMobile ? 1.55 : (isTablet ? 1.35 : 1.35);

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: responsiveHeight(
          context,
          0.022,
          min: 14,
          max: spacing,
        ),
        crossAxisSpacing: responsiveSize(context, 0.016, min: 14, max: spacing),
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (_, i) => FeatureCard(item: items[i]),
    );
  }
}
